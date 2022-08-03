// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./factory/SuperAdmin.sol";
import "./factory/Ambassador.sol";
import "./factory/VIP.sol";
import "./factory/WhiteListTokens.sol";

import "./security/ReEntrancyGuard.sol";
import "./helpers/Oracle.sol";
import "./helpers/Withdraw.sol";
import "./Interfaces/IPropertyToken.sol";

contract Metafounders is
    SuperAdmin,
    Ambassador,
    VIP,
    WhiteListTokens,
    ReEntrancyGuard,
    Oracle,
    Withdraw
{
    using SafeMath for uint256;

    /// @dev Stack too deep,
    struct SlotInfo {
        uint _amountTokens;
    }

    // This fallback/receive function
    // will keep all the Ether
    fallback() external payable {
        // Do nothing
    }

    receive() external payable {
        // Do nothing
    }

    //// @dev BUY TOKEN
    function joinWithToken(
        address _token,
        uint256 _amountTokens,
        address _wallet,
        uint256 _type,
        string memory _username
    ) external noReentrant {
        SlotInfo memory slot;
        slot._amountTokens = _amountTokens;

        require(
            slot._amountTokens > 0,
            "Join With Token: Specify an amount of token greater than zero"
        );

        /// @dev  Check that the user's token balance is enough to do the swap
        require(
            ERC20(_token).balanceOf(_msgSender()) >= slot._amountTokens,
            "Join With Token: Your balance is lower than the amount of tokens you want to sell"
        );

        /// @dev allowonce to execute the swap
        require(
            ERC20(_token).allowance(_msgSender(), address(this)) >=
                slot._amountTokens,
            "Join With Token: You don't have enough tokens to buy"
        );

        /// @dev check if a whitelist token
        require(
            isWhiteListToken(_token),
            "Buy With Custom Token: Invalid token"
        );

        /// @dev check whitelist token is available
        ERC20List memory erc20Token = getWhiteListTokenInfo(_token);
        require(
            erc20Token.active,
            "Buy With Custom Token: Token is not available"
        );

        /// @dev Transfer token to the sender  =>  sc
        require(
            IERC20(_token).transferFrom(
                _msgSender(),
                address(this),
                slot._amountTokens
            ),
            "Join With Token: Failed to transfer tokens from user to vendor"
        );

        uint256 percent = 0;
        address walletAmbassador = address(0);

        if (_wallet != address(0)) {
            VipStruct memory _vip = getVip(_username, _wallet);
            require(_vip.active, "Join With Token: The user is not a VIP");

            /// @dev verify quotas
            uint256 _quotas = _quotasVIP[_vip.addr];
            require(_quotas > 0, "Join With Token: Quotas exceeded");
            _quotasVIP[_vip.addr] = _quotas.sub(1);
            // -----------------------VIP  (bono directo)-------------------------------------

            //// @dev get the comission of the contract team
            percent = slot._amountTokens.div(100);

            //// @dev send comission to the contract vip
            uint _directPayBonus = percent.mul(directPayBonus);
            IERC20(_token).transfer(_vip.addr, _directPayBonus);

            /// @dev register transaction
            vipRegisterTransaction(
                0,
                _vip.addr,
                _msgSender(),
                _directPayBonus,
                slot._amountTokens
            );

            //// @dev le restamos la comsion del vip
            // slot._amountTokens = slot._amountTokens.sub(_directPayBonus);

            // -----------------------Ambassador (bono referido)-------------------------------------

            //// @dev send comission to the contract ambassador
            percent = slot._amountTokens.div(100);

            uint _comissionAmbassador = percent.mul(comissionAmbassador);
            IERC20(_token).transfer(
                _vip.addressAmbassador,
                _comissionAmbassador
            );

            walletAmbassador = _vip.addressAmbassador;
        } else {
            // -----------------------Ambassador (bono directo)-------------------------------------
            ///  @dev get the advisor
            AmbassadorStruct memory ambassador = getAmbassador(
                _username,
                _wallet
            );

            /// @dev verify _quotasAmbassador
            uint256 _quotas = _quotasAmbassador[ambassador.addr];
            require(_quotas > 0, "Join With Token:  Quotas exceeded");
            _quotasAmbassador[ambassador.addr] = _quotas.sub(1);

            //// @dev get the comission of the contract team
            percent = slot._amountTokens.div(100);

            //// @dev send comission to the contract vip
            uint _directPayBonus = percent.mul(directPayBonus);
            IERC20(_token).transfer(ambassador.addr, _directPayBonus);

            // -----------------------Ambassador (bono de referido)-------------------------------------

            //// @dev send comission to the contract ambassador
            percent = slot._amountTokens.div(100);

            uint _comissionAmbassador = percent.mul(comissionAmbassador);
            IERC20(_token).transfer(ambassador.addr, _comissionAmbassador);

            /// @dev register transaction
            registerTransactionAmbassador(
                0,
                ambassador.addr,
                _msgSender(),
                _comissionAmbassador,
                slot._amountTokens
            );

            walletAmbassador = ambassador.addr;
        }

        // -----------------------Admin-------------------------------------

        // slot._amountTokens = slot._amountTokens.sub(comissionAmbassador);
        percent = slot._amountTokens.div(100);
        uint _comissionAdmin = percent.mul(comissionAdmin);

        //// @dev distribuir tokens de admin
        sendComissionAdmin(2, false, _token, _comissionAdmin);

        // -----------------------SuperAdmin-------------------------------------
        // slot._amountTokens = slot._amountTokens.sub(comissionAdmin);
        sendComissionAdmin(1, false, _token, slot._amountTokens);

        /// @dev send nft token to the user
        sendNft(_type);

        /// @dev verify that the user's no exitance in the list

        VipStruct memory vip = getVip("", _msgSender());
        if (!vip.active) {
            string memory __username = Strings.toString(block.timestamp);
            _registerVIP(walletAmbassador, _msgSender(), 0, __username, true);
        }
    }

    //// @dev BUY TOKEN NATIVE
    function joinWithTokenNative(
        address _token,
        address _wallet,
        uint _type,
        string memory _username
    ) external payable noReentrant {
        /// @dev amount of token to buy
        uint _amountTokens = msg.value;
        require(
            _amountTokens > 0,
            "Join With Token: Specify an amount of token greater than zero"
        );
        /// @dev check if a whitelist token
        require(
            isWhiteListToken(_token),
            "Buy With Custom Token: Invalid token"
        );

        /// @dev check whitelist token is available
        ERC20List memory erc20Token = getWhiteListTokenInfo(_token);
        require(
            erc20Token.active,
            "Buy With Custom Token: Token is not available"
        );

        /// @dev get data oracle in usd
        uint256 latestPrice = getLatestPrice(
            erc20Token.addressOracle,
            erc20Token.addressDecimalOracle
        );

        /// @dev calculate the amount of token to buy
        uint256 valueInUsd = latestPrice.mul(_amountTokens);
        require(
            valueInUsd >= priceWhiteList,
            "Join With Token: Price is too low"
        );

        uint256 percent = 0;
        address walletAmbassador = address(0);

        if (_wallet != address(0)) {
            VipStruct memory _vip = getVip(_username, _wallet);
            require(_vip.active, "Join With Token: The user is not a VIP");

            /// @dev verify quotas
            uint256 _quotas = _quotasVIP[_vip.addr];
            require(_quotas > 0, "Join With Token: Quotas exceeded");
            _quotasVIP[_vip.addr] = _quotas.sub(1);

            // -----------------------VIP  (bono directo)-------------------------------------

            //// @dev get the comission of the contract team
            percent = _amountTokens.div(100);

            //// @dev send comission to the contract vip
            uint _directPayBonus = percent.mul(directPayBonus);
            transferNative(_vip.addr, _directPayBonus);

            vipRegisterTransaction(
                0,
                _vip.addr,
                _msgSender(),
                _directPayBonus,
                _amountTokens
            );

            //// @dev le restamos la comsion del vip
            // _amountTokens = _amountTokens.sub(_directPayBonus);

            // -----------------------Ambassador (bono referido)-------------------------------------

            //// @dev send comission to the contract ambassador
            percent = _amountTokens.div(100);

            uint _comissionAmbassador = percent.mul(comissionAmbassador);
            transferNative(_vip.addressAmbassador, _comissionAmbassador);

            vipRegisterTransaction(
                0,
                _vip.addressAmbassador,
                _msgSender(),
                _comissionAmbassador,
                _amountTokens
            );

            walletAmbassador = _vip.addressAmbassador;
        } else {
            // -----------------------Ambassador (bono directo)-------------------------------------
            ///  @dev get the advisor
            AmbassadorStruct memory ambassador = getAmbassador(
                _username,
                _wallet
            );

            /// @dev verify _quotasAmbassador
            uint256 _quotas = _quotasAmbassador[ambassador.addr];
            require(_quotas > 0, "Join With Token:  Quotas exceeded");
            _quotasAmbassador[ambassador.addr] = _quotas.sub(1);
            //// @dev get the comission of the contract team
            percent = _amountTokens.div(100);

            //// @dev send comission to the contract vip
            uint _directPayBonus = percent.mul(directPayBonus);
            transferNative(ambassador.addr, _directPayBonus);

            registerTransactionAmbassador(
                0,
                ambassador.addr,
                _msgSender(),
                _directPayBonus,
                _amountTokens
            );

            // -----------------------Ambassador (bono de referido)-------------------------------------

            //// @dev send comission to the contract ambassador
            percent = _amountTokens.div(100);

            uint _comissionAmbassador = percent.mul(comissionAmbassador);
            transferNative(ambassador.addr, _comissionAmbassador);

            /// @dev register transaction
            registerTransactionAmbassador(
                0,
                ambassador.addr,
                _msgSender(),
                _comissionAmbassador,
                _amountTokens
            );

            walletAmbassador = ambassador.addr;
        }

        // -----------------------Admin-------------------------------------

        // _amountTokens = _amountTokens.sub(comissionAmbassador);
        percent = _amountTokens.div(100);
        uint _comissionAdmin = percent.mul(comissionAdmin);

        //// @dev distribuir tokens de admin
        sendComissionAdmin(2, true, _token, _comissionAdmin);

        // -----------------------SuperAdmin-------------------------------------
        // _amountTokens = _amountTokens.sub(comissionAdmin);
        sendComissionAdmin(1, true, _token, _amountTokens);

        /// @dev send nft token to the user
        sendNft(_type);

        VipStruct memory vip = getVip("", _msgSender());
        if (!vip.active) {
            string memory __username = Strings.toString(block.timestamp);
            _registerVIP(walletAmbassador, _msgSender(), 0, __username, true);
        }
    }

    /// @dev transfer Native Token
    function transferNative(address _addrs, uint _amount) internal {
        (bool sent, bytes memory data) = address(_addrs).call{value: (_amount)}(
            ""
        );
        data;
        require(sent, "Transfer Native: Error sending money");
    }

    /// dev send nft
    function sendNft(uint256 _type) internal {
        address _tokenNft;
        if (_type == 1) {
            _tokenNft = tokenNFTVIPAddress1;
        } else if (_type == 2) {
            _tokenNft = tokenNFTVIPAddress2;
        } else if (_type == 3) {
            _tokenNft = tokenNFTVIPAddress3;
        }

        IPropertyToken(_tokenNft).mintReserved(_msgSender(), 1);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

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
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
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
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
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
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "../security/Administered.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SuperAdmin is Administered {
    using SafeMath for uint256;

    struct SAStruct {
        uint _type; // 1 = super admin || 2 = admin
        address addr;
        uint256 commission;
        bool active;
    }

    // SA = Super Admin
    mapping(uint256 => SAStruct) _SA;
    uint256 public _SACount;

    /// @dev porcentage distribution of commission
    uint256 public percentageSuperAdmin;
    uint256 public percentageAdmin;

    uint256 public directPayBonus = 10;
    uint256 public comissionAmbassador = 10;
    uint256 public comissionAdmin = 20;
    uint256 public comissionSuperAdmin = 60;
    uint256 public priceWhiteList = 100;

    address public tokenNFTVIPAddress1 = address(0);
    address public tokenNFTVIPAddress2 = address(0);
    address public tokenNFTVIPAddress3 = address(0);

    constructor() {
        _SACount = 0;
        percentageSuperAdmin = 0;
        percentageAdmin = 0;
    }

    // @dev  register staking types
    function registerSuperAdmin(
        address _addr,
        uint _percentage,
        bool _active
    ) external onlyAdminRoot {
        require(
            validPercentage(_percentage, percentageSuperAdmin),
            "Register Admin: Invalid percentage"
        );

        _SA[_SACount] = SAStruct(1, _addr, _percentage, _active);

        _SACount++;

        // @dev  update porcentage distribution
        percentageSuperAdmin = percentageSuperAdmin.add(_percentage);
    }

    function registerAdmin(
        address _addr,
        uint256 _percentage,
        bool _active
    ) external onlySuperAdmin {
        require(
            validPercentage(_percentage, percentageAdmin),
            "Register Admin: Invalid percentage"
        );

        _SA[_SACount] = SAStruct(2, _addr, _percentage, _active);

        _SACount++;

        // @dev  update porcentage distribution
        percentageAdmin = percentageAdmin.add(_percentage);
    }

    // @dev edit data admin
    function editAdmin(
        uint _type,
        uint _id,
        address _addr,
        uint256 _commission,
        bool _active
    ) external onlyAdminRoot {
        if (_type == 1) {
            _SA[_id].active = _active;
        } else if (_type == 2) {
            /// @dev  sub porcentage distribution SUPER ADMIN
            _SA[_id].commission = _commission;
            percentageSuperAdmin = percentageSuperAdmin.sub(_commission);
        } else if (_type == 3) {
            /// @dev add porcentage distribution SUPER ADMIN
            _SA[_id].commission = _commission;
            percentageSuperAdmin = percentageSuperAdmin.add(_commission);
        } else if (_type == 4) {
            /// @dev  sub porcentage distribution ADMIN
            _SA[_id].commission = _commission;
            percentageAdmin = percentageAdmin.sub(_commission);
        } else if (_type == 5) {
            /// @dev add porcentage distribution ADMIN
            _SA[_id].commission = _commission;
            percentageAdmin = percentageAdmin.add(_commission);
        } else if (_type == 6) {
            _SA[_id].addr = _addr;
        }
    }

    /// @dev edit info from contract
    function editValueAdmin(uint256 _id, uint256 _value)
        external
        onlyAdminRoot
    {
        if (_id == 1) {
            directPayBonus = _value;
        } else if (_id == 2) {
            comissionAmbassador = _value;
        } else if (_id == 3) {
            comissionAdmin = _value;
        } else if (_id == 4) {
            comissionSuperAdmin = _value;
        } else if (_id == 5) {
            priceWhiteList = _value;
        }
    }

    /// @dev set token nft address
    function setTokenAddress(address _tokenAddress, uint _type)
        external
        onlyAdminRoot
    {
        if (_type == 1) {
            tokenNFTVIPAddress1 = _tokenAddress;
        } else if (_type == 2) {
            tokenNFTVIPAddress2 = _tokenAddress;
        } else if (_type == 3) {
            tokenNFTVIPAddress3 = _tokenAddress;
        }
    }

    /// @dev valid porcentaje distribution
    function validPercentage(uint256 _percentage, uint256 _percentageCurrent)
        internal
        pure
        returns (bool)
    {
        require(
            _percentage + _percentageCurrent <= 100,
            "Valid Porcentaje: Porcentaje must be between 0 and 100"
        );

        return true;
    }

    // @dev we return all registered staking types
    function adminList() external view returns (SAStruct[] memory) {
        unchecked {
            SAStruct[] memory stakes = new SAStruct[](_SACount);
            for (uint256 i = 0; i < _SACount; i++) {
                SAStruct storage s = _SA[i];
                stakes[i] = s;
            }
            return stakes;
        }
    }

    /// @dev send comission to the contract team
    function sendComissionAdmin(
        uint _type,
        bool _isNative,
        address _token,
        uint256 _amount
    ) public payable {
        /// @dev get the comission of the contract team
        uint256 percent = _amount / 100;

        for (uint256 i = 0; i < _SACount; i++) {
            SAStruct storage s = _SA[i];
            if (s.active && s._type == _type) {
                uint amount = percent.mul(s.commission);
                if (_isNative) {
                    require(
                        payable(s.addr).send(amount),
                        "Not enought ether to pay for the Token Native"
                    );
                } else {
                    require(
                        IERC20(_token).transfer(s.addr, amount),
                        "Not enought tokens to pay for the Token No Native"
                    );
                }
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../security/Administered.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../Interfaces/IPropertyToken.sol";

contract Ambassador is Administered {
    // @dev SafeMath library
    using SafeMath for uint256;

    /// ----------------------------Register Ambassador--------------------------------------------

    /// @notice Ambassador data struct
    /// @dev Ambassador data struct
    /// Properties:
    /// - createdBy: Wallet address of ambassador creator
    /// - addr: Wallet address of the ambassador
    /// - username: User name of the ambassador
    /// - commission: Percentage of commission
    /// - active: Document status
    struct AmbassadorStruct {
        address createdBy;
        address addr;
        string username;
        uint256 commission;
        bool active;
    }


    /// @notice Mapping of VIP quotes
    /// @dev Mapping of VIP quotes
    mapping(address => uint) public __withdrawQuotaAmbToVip;


    /// @notice Mapping of claimed vip quota to ambassador
    /// @dev Mapping of claimed vip quota to ambassador
    mapping(address => bool) public _isWithdrawVip;

    /// @dev add an _Ambassador to the factory
    mapping(uint256 => AmbassadorStruct) private _Ambassador;
    uint256 public AmbassadorCount;

    /// @dev quotas for ambassadors
    mapping(address => uint256) public _quotasAmbassador;

    address public tokenNFTAMBASSADORAddress = address(0);

    uint public _quotaAmbassadorVip = 0;

    /// ----------------------------Register Transacion--------------------------------------------

    /// @dev register transaction
    struct RegisterAmbassador {
        uint256 _pairId;
        address walletAmbassador;
        address wallet;
        uint256 commission;
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => mapping(uint256 => RegisterAmbassador))
        private _RegisterListAmbassador;

    mapping(address => uint256) public countTransactionAmbassador;

    /// ---------------------------- Fin Register Transacion--------------------------------------------

    constructor() {
        AmbassadorCount = 0;
    }

    /// @dev register an _Ambassador to the factory
    function registerAmbassador(
        address _addr,
        uint256 _quotas,
        string memory _username,
        uint256 _commission,
        bool _active
    ) external onlyAdmin {
        require(_addr != address(0), "Add Advisor: Wallet cannot be empty");

        AmbassadorStruct memory businessPartners = getAmbassador(
            _username,
            address(0)
        );

        require(
            businessPartners.active == false,
            "Add Advisor: Username already exist"
        );

        /// @dev  save the pair
        _Ambassador[AmbassadorCount] = AmbassadorStruct(
            _msgSender(),
            _addr,
            _username,
            _commission,
            _active
        );

        /// @dev count the number of pairs
        AmbassadorCount++;

        /// @dev count the number of advisors
        countTransactionAmbassador[_addr] = 0;

        /// @dev cupos de ambasador
        _quotasAmbassador[_addr] = _quotasAmbassador[_addr].add(_quotas);

        /// @dev send NFT to Ambassador
        IPropertyToken(tokenNFTAMBASSADORAddress).mintReserved(_addr, 1);
    }

    /// @dev edit business partner
    function editAmbassador(
        uint8 _type,
        uint _quotas,
        address _addr, /// buscar por adddres
        string memory _username, /// buscar por username
        address _wallet,
        uint256 _commission,
        bool _active
    ) external onlyAdmin {
        unchecked {
            for (uint256 i = 0; i < AmbassadorCount; i++) {
                if (
                    keccak256(abi.encodePacked(_Ambassador[i].username)) ==
                    keccak256(abi.encodePacked(_username)) ||
                    _Ambassador[i].addr == _addr
                ) {
                    if (_type == 1) {
                        _Ambassador[i].addr = _wallet;
                    } else if (_type == 2) {
                        _Ambassador[i].username = _username;
                    } else if (_type == 3) {
                        _Ambassador[i].commission = _commission;
                    } else if (_type == 4) {
                        _Ambassador[i].active = _active;
                    } else if (_type == 5) {
                        _quotasAmbassador[_addr] = _quotas;
                    }
                    return;
                }
            }
        }
    }

    /// @dev is collection exist
    /// @dev get the advisor by username
    function getAmbassador(string memory _username, address _addr)
        public
        view
        returns (AmbassadorStruct memory)
    {
        unchecked {
            for (uint256 i = 0; i < AmbassadorCount; i++) {
                if (
                    keccak256(abi.encodePacked(_Ambassador[i].username)) ==
                    keccak256(abi.encodePacked(_username)) ||
                    _Ambassador[i].addr == _addr
                ) {
                    return _Ambassador[i];
                }
            }
            return AmbassadorStruct(address(0), address(0), "", 0, false);
        }
    }

    /// @dev get the advisor by username
    function AmbassadorList()
        external
        view
        returns (AmbassadorStruct[] memory)
    {
        unchecked {
            AmbassadorStruct[] memory p = new AmbassadorStruct[](
                AmbassadorCount
            );

            for (uint256 i = 0; i < AmbassadorCount; i++) {
                AmbassadorStruct storage s = _Ambassador[i];
                p[i] = s;
            }

            return p;
        }
    }

    /// @dev  register of transaction
    function registerTransactionAmbassador(
        uint256 _pairId,
        address _walletAmbassador,
        address _walletBuyed,
        uint256 _commission,
        uint256 _amount
    ) internal {
        /// @dev count the number of pairs
        uint256 _count = countTransactionAmbassador[_walletAmbassador];

        /// @dev save transaction
        _RegisterListAmbassador[_walletAmbassador][_count] = RegisterAmbassador(
            _pairId,
            _walletAmbassador,
            _walletBuyed,
            _commission,
            _amount,
            block.timestamp
        );

        /// @dev count the number of pairs
        countTransactionAmbassador[_walletAmbassador] = _count.add(1);
    }

    /// @dev get list of transaction
    /// @dev get the advisor by username
    function transactionAmbassadorList(
        address _walletAmbassador,
        uint256 _from,
        uint256 _to
    ) external view returns (RegisterAmbassador[] memory) {
        unchecked {
            /// @dev count the number of pairs
            uint256 _count = countTransactionAmbassador[_walletAmbassador];
            uint256 to = (_to > _count) ? _count : _to;

            RegisterAmbassador[] memory p = new RegisterAmbassador[](to);

            for (uint256 i = _from; i < to; i++) {
                RegisterAmbassador storage s = _RegisterListAmbassador[
                    _walletAmbassador
                ][i];
                p[i] = s;
            }

            return p;
        }
    }

    //// @dev set winrar
    function setAmountQuota(uint256 _quota) external onlyAdmin {
        _quotaAmbassadorVip = _quota;
    }

    /// @dev set token nft address
    function setTokenAddressAmbassador(address _tokenAddress)
        external
        onlyAdminRoot
    {
        tokenNFTAMBASSADORAddress = _tokenAddress;
    }


    /// @notice Update VIP Quota for default
    /// @dev Update VIP Quota for default
    /// @param _quota                                       Quota to update
    function setYPQuotas(uint256 _quota)
        external
    {
        __withdrawQuotaAmbToVip[_msgSender()] = _quota;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../security/Administered.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Ambassador.sol";

contract VIP is Administered, Ambassador {
    // @dev SafeMath library
    using SafeMath for uint256;

    /// @dev struct

    /// @notice Vip data struct
    /// @dev Vip data struct
    /// Properties:
    /// - addressAmbassador: Wallet address of the ambassador
    /// - addr: Wallet address of the VIP
    /// - username: User name of the VIP
    /// - active: Document status
    struct VipStruct {
        address addressAmbassador;
        address addr;
        string username;
        bool active;
    }

    /// @dev add an advisor to the factory
    mapping(uint256 => VipStruct) private _VipPartners;
    uint256 public vipCount;

    /// @dev quotas for ambassadors
    mapping(address => uint256) public _quotasVIP;

    /// ----------------------------Register Transacion--------------------------------------------

    /// @dev register transaction
    struct RegisterVip {
        uint256 _pairId;
        address walletVip;
        address wallet;
        uint256 commission;
        uint256 amount;
        uint256 timestamp;
    }
    mapping(address => mapping(uint256 => RegisterVip))
        private _RegisterListVip;
    mapping(address => uint256) public countTransactionVip;

    /// ---------------------------- Fin Register Transacion--------------------------------------------

    constructor() {
        vipCount = 0;
    }

    /// ----------------------------Register VIP--------------------------------------------
    function registerVIP(
        address _addr,
        uint256 _quotas,
        string memory _username,
        bool _active
    ) external onlyAmbassador {
        _registerVIP(_msgSender(), _addr, _quotas, _username, _active);
    }

    /// @dev register an _VIP to the factory
    function _registerVIP(
        address _addressAmbassador,
        address _addr,
        uint256 _quotas,
        string memory _username,
        bool _active
    ) internal {
        require(_addr != address(0), "Add Advisor: Wallet cannot be empty");

        /// @dev verify quotas _quotas > 0
        uint256 _myQuotas = _quotasAmbassador[_addressAmbassador];
        int256 _quotasAvailable = int256(_myQuotas.sub(_quotas));

        require(
            _myQuotas > 0 && _quotasAvailable >= 0,
            "Add Advisor: Quotas exceeded"
        );

        VipStruct memory businessPartners = getVip(_username, address(0));

        require(
            businessPartners.active == false,
            "Add Advisor: Username already exist"
        );

        /// @dev  save the pair
        _VipPartners[vipCount] = VipStruct(
            _addressAmbassador,
            _addr,
            _username,
            _active
        );

        /// @dev count the number of pairs
        vipCount++;

        /// @dev count the number of advisors
        countTransactionVip[_addr] = 0;

        /// @dev quotas for ambassadors
        _quotasVIP[_addr] = _quotasVIP[_addr].add(_quotas);

        /// @dev remove quota for ambassadors
        _quotasAmbassador[_addressAmbassador] = uint256(_quotasAvailable);
    }

    /// @dev edit business partner
    function editVIP(
        uint8 _type,
        address _wallet, /// buscar por adddres
        string memory _username, /// buscar por username
        address _addr,
        uint256 _quotas,
        bool _active
    ) public onlyAmbassador {
        unchecked {
            for (uint256 i = 0; i < vipCount; i++) {
                if (
                    keccak256(abi.encodePacked(_VipPartners[i].username)) ==
                    keccak256(abi.encodePacked(_username)) ||
                    _VipPartners[i].addr == _wallet
                ) {
                    if (_type == 1) {
                        _VipPartners[i].addr = _addr;
                    } else if (_type == 2) {
                        _VipPartners[i].username = _username;
                    } else if (_type == 3) {
                        _VipPartners[i].active = _active;
                    } else if (_type == 4) {
                        /// @dev verify quotas _quotas > 0
                        uint256 _myQuotas = _quotasAmbassador[_msgSender()];
                        int256 _quotasAvailable = int256(
                            _myQuotas.sub(_quotas)
                        );

                        require(
                            _myQuotas > 0 && _quotasAvailable >= 0,
                            "Add VIP: Quotas exceeded"
                        );

                        _quotasVIP[_addr] = _quotas;
                    }

                    return;
                }
            }
        }
    }

    //// @dev withdraw the quota vip
    function withdrawQuota() external {
        VipStruct memory vip = getVip("", _msgSender());
        require(vip.active, "Withdraw Quota: User is not active");

        bool isWithdraw = _isWithdrawVip[vip.addr];
        require(!isWithdraw, "Withdraw quota: Already withdrawn");

        uint256 _qAmbassadorCount = _quotasAmbassador[vip.addressAmbassador];
        uint256 _qAmbasadorVipDefault = __withdrawQuotaAmbToVip[
            vip.addressAmbassador
        ];
        int256 _qAvailabes = int256(_qAmbassadorCount.sub(_qAmbasadorVipDefault));

        /// @dev check Ambassador quotas availables
        require(_qAmbassadorCount > 0, "Withdraw Quota: ambassador no have quota");

        /// @dev check Ambassador quotas for assign to VIP
        require(_qAvailabes >= 0, "Withdraw Quota: no quotas availables to withdraw");

        /// @dev remove quota for ambassadors
        _quotasAmbassador[vip.addressAmbassador] = uint256(_qAvailabes);

        /// @dev add quota for VIP
        editVIP(5, vip.addr, "", vip.addr, _qAmbasadorVipDefault, false);

        /// @dev set the withdraw flag
        _isWithdrawVip[vip.addr] = true;
    }

    /// @dev get the advisor by username
    function getVip(string memory _username, address _addr)
        public
        view
        returns (VipStruct memory)
    {
        unchecked {
            for (uint256 i = 0; i < vipCount; i++) {
                if (
                    keccak256(abi.encodePacked(_VipPartners[i].username)) ==
                    keccak256(abi.encodePacked(_username)) ||
                    _VipPartners[i].addr == _addr
                ) {
                    return _VipPartners[i];
                }
            }
            return VipStruct(address(0), address(0), "", false);
        }
    }

    /// @dev get the advisor by username
    function vipList() external view returns (VipStruct[] memory) {
        unchecked {
            VipStruct[] memory p = new VipStruct[](vipCount);

            for (uint256 i = 0; i < vipCount; i++) {
                VipStruct storage s = _VipPartners[i];
                p[i] = s;
            }

            return p;
        }
    }

    /// @dev  register of transaction
    function vipRegisterTransaction(
        uint256 _pairId,
        address _walletVip,
        address _walletBuyed,
        uint256 _commission,
        uint256 _amount
    ) internal {
        /// @dev count the number of pairs
        uint256 _count = countTransactionVip[_walletVip];

        /// @dev save transaction
        _RegisterListVip[_walletVip][_count] = RegisterVip(
            _pairId,
            _walletVip,
            _walletBuyed,
            _commission,
            _amount,
            block.timestamp
        );

        /// @dev count the number of pairs
        countTransactionVip[_walletVip] = _count.add(1);
    }

    /// @dev get list of transaction
    /// @dev get the advisor by username
    function vipTransactionList(
        address _walletAdvisor,
        uint256 _from,
        uint256 _to
    ) external view returns (RegisterVip[] memory) {
        unchecked {
            /// @dev count the number of pairs
            uint256 _count = countTransactionVip[_walletAdvisor];
            uint256 to = (_to > _count) ? _count : _to;

            RegisterVip[] memory p = new RegisterVip[](to);

            for (uint256 i = _from; i < to; i++) {
                RegisterVip storage s = _RegisterListVip[_walletAdvisor][i];
                p[i] = s;
            }

            return p;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../security/Administered.sol";

contract WhiteListTokens is Administered {

    /// @dev struct
    struct ERC20List {
        address tokenAddress;                           // Token address
        address addressOracle;                          // Address of the Oracle
        uint256 addressDecimalOracle;                   // Decimal of the Oracle
        bool active;                                    // Status of the token
        bool isNative;                                  // Is Native token
    }


    struct ERC20AddressList {
        address tokenAddress;
        uint256 index;
    }

    /// @dev List of addresses that have a number of reserved tokens for whitelist
    mapping(uint256 => ERC20List) whitelistTokensPay;

    /// @dev
    mapping(address => ERC20AddressList) whitelistTokenAddress;

    uint256 public whitelistTokenCount;

    constructor(){
        whitelistTokenCount = 0;
    }


    /// @notice Add Token
    /// @dev Add a token to the whitelist
    /// @param _tokenAddress                            Address of the token contract
    /// @param _addressOracle                           Address of the Oracle contract
    /// @param _addressDecimalOracle                    Decimals of the Oracle contract
    /// @param _active                                  Status of the pair
    /// @param _isNative                                Is Native token
    function storeWhitListToken(
        address _tokenAddress,
        address _addressOracle,
        uint256 _addressDecimalOracle,
        bool _active,
        bool _isNative
    ) 
        external
        onlyUser
    {
        /// @dev verificar que la coleccion no exista
        require(
            isWhiteListToken(_tokenAddress) == false,
            "Add Token Collection already exist"
        );

        uint256 pointer = whitelistTokenCount;

        /// @dev add token to whitelist
        whitelistTokensPay[pointer] = ERC20List(
            _tokenAddress,
            _addressOracle,
            _addressDecimalOracle,
            _active,
            _isNative
        );

        /// @dev Add token to address list
        whitelistTokenAddress[_tokenAddress] = ERC20AddressList(
            _tokenAddress,
            pointer
        );

        whitelistTokenCount++;
    }


    function whitelistTokensPayList() 
        external 
        view 
        returns (ERC20List[] memory) 
    {
        unchecked {
            ERC20List[] memory p = new ERC20List[](whitelistTokenCount);
            for (uint256 i = 0; i < whitelistTokenCount; i++) {
                ERC20List storage s = whitelistTokensPay[i];
                p[i] = s;
            }
            return p;
        }
    }


    /// @notice Disable Token
    /// @dev Disable token from the whitelist
    /// @param _tokenAddress                            Address of the token contract
    function disableWhiteListToken(address _tokenAddress) 
        external 
        onlyUser 
    {
        /// @dev verificar que la coleccion exista
        require(
            isWhiteListToken(_tokenAddress) == true,
            "Disable Whitelist Token: Invalid token address"
        );

        /// @dev Get index of token
        ERC20AddressList storage _row = whitelistTokenAddress[_tokenAddress];

        /// @dev remove token from whitelist
        whitelistTokensPay[_row.index].active = false;
    }


    /// @notice Update Pair
    /// @dev Update values of a pair
    /// @param _type                                Type of change to be made
    /// @param _address                             Address of the contract
    /// @param _decimal                             Decimal of the contract
    /// @param _bool                                Status of the pair
    function updateWhiteListToken(
        uint256 _id,
        uint256 _type,
        address _address,
        uint256 _decimal,
        bool _bool
    ) 
        public 
        onlyUser 
    {

        /// @dev Update oracle address
        if (_type == 1) {
            whitelistTokensPay[_id].addressOracle = _address;

        /// @dev Update oracle decimals
        } else if (_type == 2) {
            whitelistTokensPay[_id].addressDecimalOracle = _decimal;

        /// @dev Update token status
        } else if (_type == 3) {
            whitelistTokensPay[_id].active = _bool;
        
        /// @dev Update token native status
        } else if (_type == 4) {
            whitelistTokensPay[_id].isNative = _bool;
        } 
    }


    /// @notice Verify Token
    /// @dev Verify if the token is in the whitelist
    /// @param _tokenAddress                            Address of the token contract
    function isWhiteListToken(address _tokenAddress) 
        public
        view
        returns (bool) 
    {
        if(whitelistTokenAddress[_tokenAddress].tokenAddress == address(0x0)){
            return false;
        } else {
            return true;
        }
    }


    function getWhiteListTokenInfo(address _tokenAddress)
        internal
        view
        returns (ERC20List memory)
    {
        require(
            isWhiteListToken(_tokenAddress),
            "Invalid Token"
        );

        ERC20AddressList storage row = whitelistTokenAddress[_tokenAddress];
        return whitelistTokensPay[row.index];
    }

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract ReEntrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Oracle {
    using SafeMath for uint256;

    // @dev Returns the latest price
    function getLatestPrice(address _oracle, uint256 _decimal)
        public
        view
        returns (uint256)
    {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(_oracle);
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price) * 10**_decimal;
    }

    // @dev transforma los montos a 18 decimales
    function transformAmountTo18Decimal(uint256 _amount, uint256 _decimal)
        internal
        pure
        returns (uint256)
    {
        if (_decimal == 18) {
            return _amount;
        } else if (_decimal == 8) {
            return _amount.mul(10**10);
        } else if (_decimal == 6) {
            return _amount.mul(10**12);
        }
        return 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../security/Administered.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Withdraw is Administered {
    constructor() {}

    // @dev Allow the owner of the contract to withdraw BNB Owner
    function withdrawTokenNative(uint256 amount)
        external
        payable
        onlyAdminRoot
    {
        require(
            payable(address(_msgSender())).send(amount),
            "withdrawTokenNative: Failed to transfer token to fee contract"
        );
    }

    // @dev Allow the owner of the contract to withdraw BNB Owner
    function withdrawTokenOnwer(address _token, uint256 _amount)
        external
        onlyAdminRoot
    {
        require(
            IERC20(_token).transfer(_msgSender(), _amount),
            "withdrawTokenOnwer: Failed to transfer token to Onwer"
        );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IPropertyToken {

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function mintReserved(address _address, uint256 _amount) external;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Administered
 * @notice Implements Admin and User roles.
 */
contract Administered is AccessControl {
    bytes32 public constant USER_ROLE_SUPER_ADMIN = keccak256("SUPER_ADMIN");
    bytes32 public constant USER_ROLE_ADMIN = keccak256("ADMIN");
    bytes32 public constant USER_ROLE_AMBASSADOR = keccak256("AMBASSADOR");
    bytes32 public constant USER_ROLE_USER = keccak256("USER");

    /// @dev Add `root` to the admin role as a member.
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setRoleAdmin(USER_ROLE_SUPER_ADMIN, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(USER_ROLE_ADMIN, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(USER_ROLE_AMBASSADOR, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(USER_ROLE_USER, DEFAULT_ADMIN_ROLE);

        /// @dev asigano el el creador d econtrato como un super admin
        grantRole(USER_ROLE_SUPER_ADMIN, _msgSender());
    }

    /// @dev Restricted to members of the admin role.
    modifier onlyAdminRoot() {
        require(isAdmin(_msgSender()), "Restricted to admins.");
        _;
    }

    /// @dev Restricted to members of the user role.
    modifier onlySuperAdmin() {
        require(isUser(_msgSender(), 0), "Restricted to Super Admin.");
        _;
    }

    modifier onlyAdmin() {
        require(isUser(_msgSender(), 1), "Restricted to Admin.");
        _;
    }

    modifier onlyAmbassador() {
        require(isUser(_msgSender(), 2), "Restricted to Ambassador.");
        _;
    }

    modifier onlyUser() {
        require(isUser(_msgSender(), 3), "Restricted to User.");
        _;
    }

    /// @dev Return `true` if the account belongs to the admin role.
    function isAdmin(address account) public view virtual returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    /// @dev Add an account to the admin role. Restricted to admins.
    function addAdminRoot(address account) public virtual onlyAdminRoot {
        grantRole(DEFAULT_ADMIN_ROLE, account);
    }

    function addUser(address account) public virtual onlyAdminRoot {
        return grantRole(USER_ROLE_USER, account);
    }

    /// @dev Add an account to the user role. Restricted to admins.
    function addSuperAdmin(address account) public virtual onlyAdminRoot {
        return grantRole(USER_ROLE_SUPER_ADMIN, account);
    }

    function addAdmin(address account) public virtual onlySuperAdmin {
        return grantRole(USER_ROLE_ADMIN, account);
    }

    function addAmbassador(address account) public virtual onlyAdmin {
        return grantRole(USER_ROLE_AMBASSADOR, account);
    }

    /// @dev Return `true` if the account belongs to the user role.
    function isUser(address account, uint256 typeAccount)
        public
        view
        virtual
        returns (bool)
    {
        if (typeAccount == 0) {
            return hasRole(USER_ROLE_SUPER_ADMIN, account);
        } else if (typeAccount == 1) {
            return hasRole(USER_ROLE_ADMIN, account);
        } else if (typeAccount == 2) {
            return hasRole(USER_ROLE_AMBASSADOR, account);
        } else if (typeAccount == 3) {
            return hasRole(USER_ROLE_USER, account);
        } else {
            return false;
        }
    }

    /// @dev Remove an account from the user role. Restricted to admins.
    function removeUser(address account, uint256 typeAccount)
        public
        virtual
        onlyAdminRoot
    {
        if (typeAccount == 0) {
            return revokeRole(USER_ROLE_SUPER_ADMIN, account);
        } else if (typeAccount == 1) {
            return revokeRole(USER_ROLE_ADMIN, account);
        } else if (typeAccount == 2) {
            return revokeRole(USER_ROLE_AMBASSADOR, account);
        } else if (typeAccount == 3) {
            return revokeRole(USER_ROLE_USER, account);
        }
    }

    /// @dev Remove oneself from the admin role.
    function renounceAdmin() public virtual {
        renounceRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

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
        _checkRole(role);
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
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
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
     *
     * May emit a {RoleGranted} event.
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
     *
     * May emit a {RoleRevoked} event.
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
     *
     * May emit a {RoleRevoked} event.
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
     * May emit a {RoleGranted} event.
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
     *
     * May emit a {RoleGranted} event.
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
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
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
pragma solidity ^0.8.0;

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