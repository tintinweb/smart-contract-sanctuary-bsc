// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/utils/math/SafeMath.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IFireCatTreasury} from "../src/interfaces/IFireCatTreasury.sol";
import {IFireCatNFT} from "../src/interfaces/IFireCatNFT.sol";
import {FireCatTransfer} from "../src/utils/FireCatTransfer.sol";

/**
 * @title FireCat's treasury Contract
 * @notice Add treasury to this contract
 * @author FireCat Finance
 */
contract FireCatTreasury is IFireCatTreasury, FireCatTransfer {
    using SafeMath for uint256;

    event AddTreasury(address user_, uint256 amount_, uint256 totalTreasury_);
    event SwapTreasury(address user_, uint256 tokenId_, uint256 amount_);
    event WithdrawTreasury(address user_, uint256 amount_, uint256 totalTreasury_);
    event SetSwapOn(bool swapOn_);
    event SetFireCatProxy(address fireCatProxy_);
    event SetFireCatNFT(address fireCatNFT_);
    
    address public fireCatNFT;
    address public fireCatProxy;

    bool private swapOn;
    uint private _totalTreasury;
    address private  _treasuryToken;

    /**
    * @dev Mapping from tokenId to amount of LP.
    */
    mapping(uint256 => uint256) private _treasurys;

    constructor(address token) {
        _treasuryToken = token;
    }

    modifier onlyProxy() {
        require(msg.sender == fireCatProxy, "TRS:E00");
        _;
    }

    /// @inheritdoc IFireCatTreasury
    function totalTreasury() public view returns (uint256) {
        return _totalTreasury;
    }

    /// @inheritdoc IFireCatTreasury
    function treasuryOf(uint256 tokenId) public view returns (uint256) {
        return _treasurys[tokenId];
    }

    /// @inheritdoc IFireCatTreasury
    function treasuryToken() public view returns (address) {
        return _treasuryToken;
    }

    /// @inheritdoc IFireCatTreasury
    function addTreasury(address user, uint256 tokenId, uint256 addAmount) external onlyProxy returns (uint) {
        // totalTreasury + actualAddAmount
        require(IERC20(_treasuryToken).balanceOf(msg.sender) >= addAmount, "TRS:E01");
        uint totalTreasuryNew;
        uint actualAddAmount;

        actualAddAmount = doTransferIn(_treasuryToken, msg.sender, addAmount);
        totalTreasuryNew = _totalTreasury.add(actualAddAmount);

        require(totalTreasuryNew >= _totalTreasury, "TRS:E02");

        _totalTreasury = totalTreasuryNew;
        _treasurys[tokenId] = actualAddAmount;

        emit AddTreasury(user, actualAddAmount, totalTreasuryNew);
        return actualAddAmount;
    }

    /// @inheritdoc IFireCatTreasury
    function swapTreasury(uint256 tokenId) external returns (uint) {
        require(swapOn, "TRS:E04");
        require(IFireCatNFT(fireCatNFT).ownerOf(tokenId) == msg.sender, "TRS:E05");
        require(_treasurys[tokenId] > 0, "TRS:E01");
        uint totalTreasuryNew;
        uint actualSubAmount;

        uint amount = _treasurys[tokenId];
        actualSubAmount = doTransferOut(_treasuryToken, msg.sender, amount);
        totalTreasuryNew = _totalTreasury.sub(actualSubAmount);

        require(totalTreasuryNew <= _totalTreasury, "TRS:E03");

        _totalTreasury = totalTreasuryNew;
        _treasurys[tokenId] = 0;

        emit SwapTreasury(msg.sender, tokenId, amount);
        return actualSubAmount;
    }

    /// @inheritdoc IFireCatTreasury
    function withdrawTreasury(uint256 amount) external nonReentrant onlyOwner returns (uint) {
        require(amount <= _totalTreasury, "TRS:E03");
        uint totalTreasuryNew;
        uint actualSubAmount;

        actualSubAmount = doTransferOut(_treasuryToken, msg.sender, amount);
        // totalTreasury - actualAddAmount
        totalTreasuryNew = _totalTreasury.sub(actualSubAmount);

        require(totalTreasuryNew <= _totalTreasury, "TRS:E03");
        _totalTreasury = totalTreasuryNew;
        
        emit WithdrawTreasury(msg.sender, actualSubAmount, totalTreasuryNew);
        return actualSubAmount;
    }

    /// @inheritdoc IFireCatTreasury
    function withdrawRemaining(address token, uint256 amount) external nonReentrant onlyOwner returns (uint) {
        require(token != _treasuryToken, "TRS:E06");
        return withdraw(token, amount);
    }

    /// @inheritdoc IFireCatTreasury
    function setSwapOn(bool swapOn_) external onlyOwner {
        swapOn = swapOn_;
        emit SetSwapOn(swapOn_);
    }
    
    /// @inheritdoc IFireCatTreasury
    function setFireCatProxy(address fireCatProxy_) external onlyOwner {
        fireCatProxy = fireCatProxy_;
        emit SetFireCatProxy(fireCatProxy_);
    }

    /// @inheritdoc IFireCatTreasury
    function setFireCatNFT(address fireCatNFT_) external onlyOwner {
        fireCatNFT = fireCatNFT_;
        emit SetFireCatNFT(fireCatNFT_);
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
pragma solidity ^0.8.13;

/**
* @notice IFireCatTreasury
*/
interface IFireCatTreasury {

    /**
    * @notice All treasury of contract.
    * @dev Fetch data from _totalTreasury.
    * @return totalTreasury.
    */
    function totalTreasury() external view returns (uint256);

    /**
    * @notice check treasury by address.
    * @dev Fetch treasury from _treasurys.
    * @param tokenId uint256.
    * @return treasury.
    */
    function treasuryOf(uint256 tokenId) external view returns (uint256);

    /**
    * @notice The treasury token of contract.
    * @dev Fetch data from _treasuryToken.
    * @return treasuryToken.
    */
    function treasuryToken() external view returns (address);

    /**
    * @notice The interface of treasury adding.
    * @dev add liquidity pool token to contract.
    * @param user address.
    * @param tokenId uint256.
    * @param addAmount uint256.
    * @return actualAddAmount.
    */
    function addTreasury(address user, uint256 tokenId, uint256 addAmount) external returns (uint);
    /**
    * @notice The interface of treasury exchange.
    * @dev Exchange LP token from NFT.
    * @param tokenId uint256.
    * @return actualSubAmount.
    */
    function swapTreasury(uint256 tokenId) external returns (uint);

    /**
    * @notice The interface of treasury withdrawn.
    * @dev Trasfer LP Token to owner.
    * @param amount uint256.
    * @return actualSubAmount.
    */
    function withdrawTreasury(uint256 amount) external returns (uint);

    /**
    * @notice The interface of IERC20 withdrawn, not include treausury token.
    * @dev Trasfer token to owner.
    * @param amount uint256.
    * @return actualSubAmount.
    */
    function withdrawRemaining(address token, uint256 amount) external returns (uint);

    /**
    * @notice The exchange switch of the treasury.
    * @dev set bool to swapOn.
    * @param swapOn_ bool.
    */
    function setSwapOn(bool swapOn_) external;
    
    /**
    * @notice set the fireCat proxy contract.
    * @dev set to fireCatProxy.
    * @param fireCatProxy_ address.
    */
    function setFireCatProxy(address fireCatProxy_) external;

    /**
    * @notice set the fireCat NFT contract.
    * @dev set to fireCatNFT.
    * @param fireCatNFT_ address.
    */
    function setFireCatNFT(address fireCatNFT_) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

/**
* @notice IFireCatNFT
*/
interface IFireCatNFT is IERC721 {

    /**
     * @notice Return total amount of supply, not include destoryed.
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() external view returns (uint256);

    /**
    * @notice Latest ID not yet minted.
    * @dev currentTokenId add 1.
    * @return tokenId
    */
    function freshTokenId() external view returns (uint256);

    /**
    * @notice check user whether has minted.
    * @dev fetch data from _hasMinted.
    * @param user user_address.
    * @return minted
    */
    function hasMinted(address user) external view returns (bool);

    /**
    * @notice the supply limit of NFT, set by owner.
    * @return supplyLimit
    */
    function supplyLimit() external view returns (uint256);

    /**
    * @notice the highest level of NFT, set by owner.
    * @return highestLevel 
    */
    function highestLevel() external view returns (uint256);

    /**
    * @notice check tokenId by address.
    * @dev fetch data from _ownerTokenId.
    * @param owner user_address.
    * @return tokenId
    */
    function tokenIdOf(address owner) external view returns (uint256[] memory);

    /**
    * @notice check token level by Id.
    * @dev fetch data from _tokenLevel.
    * @param tokenId uint256.
    * @return tokenLevel
    */
    function tokenLevelOf(uint256 tokenId) external view returns (uint256);

    /**
    * @notice Metadata of NFT. 
    * @dev Combination of baseURI and tokenLevel
    * @param tokenId uint256.
    * @return json
    */
    function tokenURI(uint256 tokenId) external view returns (string memory);
    
    /**
    * @notice Use for airdrop.
    * @dev access: onlyOwner.
    * @param recipient address.
    * @return newTokenId
    */
    function mintTo(address recipient) external returns (uint256);

    /**
    * @notice Use for firecat proxy.
    * @dev access: onlyProxy.
    * @param recipient address.
    * @return newTokenId
    */
    function proxyMint(address recipient) external returns (uint256);
    
    /**
    * @notice Required two contracts to upgrade NFT: upgradeProxy and upgradeStorage.
    * @dev Upgrade needs to get permission from upgradeProxy.
    * @param tokenId uint256.
    */
    function upgradeToken(uint256 tokenId) external;

    /**
    * @notice Increase the supply of NFT as needed.
    * @dev set to _supplyLimit.
    * @param amount_ uint256.
    */
    function addSupply(uint256 amount_) external;

    /**
    * @dev Burn an ERC721 token.
    * @param tokenId_ uint256.
     */
    function burn(uint256 tokenId_) external;

    /**
    * @notice Set the highest level of NFT.
    * @dev set to _highestLevel.
    * @param level_ uint256.
    */
    function setHighestLevel(uint256 level_) external;

    /**
    * @notice set the upgrade logic contract of NFT.
    * @dev set to upgradeProxy.
    * @param upgradeProxy_ address.
    */
    function setUpgradeProxy(address upgradeProxy_) external;

    /**
    * @notice set the upgrade condtiions contract of NFT.
    * @dev set to upgradeStorage.
    * @param upgradeStorage_ address.
    */
    function setUpgradeStorage(address upgradeStorage_) external;

    /**
    * @notice The proxy contract is responsible for the minting。
    * @dev set to fireCatProxy.
    * @param fireCatProxy_ address.
    */
    function setFireCatProxy(address fireCatProxy_) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

contract FireCatTransfer is Ownable, ReentrancyGuard {

    event Withdraw(address sender_, address token_, uint256 amount_);

     /**
     * @dev Performs a transfer in, reverting upon failure. Returns the amount actually transferred to the protocol, in case of a fee.
     * @param token_ address.
     * @param from_ address.
     * @param amount_ uint.
     * @return transfer_num.
     */
    function doTransferIn(address token_, address from_, uint amount_) internal returns (uint) {
        uint balanceBefore = IERC20(token_).balanceOf(address(this));
        IERC20(token_).transferFrom(from_, address(this), amount_);

        bool success;
        assembly {
            switch returndatasize()
                case 0 {                       // This is a non-standard ERC-20
                    success := not(0)          // set success to true
                }
                case 32 {                      // This is a compliant ERC-20
                    returndatacopy(0, 0, 32)
                    success := mload(0)        // Set `success = returndata` of external call
                }
                default {                      // This is an excessively non-compliant ERC-20, revert.
                    revert(0, 0)
                }
        }
        require(success, "TOKEN_TRANSFER_IN_FAILED");
        uint balanceAfter = IERC20(token_).balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "TOKEN_TRANSFER_IN_OVERFLOW");
        return balanceAfter - balanceBefore;  // underflow already checked above, just subtract
    }

    /**
     * @dev Performs a transfer out, ideally returning an explanatory error code upon failure tather than reverting.
     *  If caller has not called checked protocol's balance, may revert due to insufficient cash held in the contract.
     *  If caller has checked protocol's balance, and verified it is >= amount, this should not revert in normal conditions.
     * @param token_ address.
     * @param to_ address.
     * @param amount_ uint.
     * @return transfer_num.
     */
    function doTransferOut(address token_, address to_, uint256 amount_) internal returns (uint) {
        uint balanceBefore = IERC20(token_).balanceOf(address(this));
        IERC20(token_).transfer(to_, amount_);

        bool success;
        assembly {
            switch returndatasize()
                case 0 {                      // This is a non-standard ERC-20
                    success := not(0)          // set success to true
                }
                case 32 {                     // This is a compliant ERC-20
                    returndatacopy(0, 0, 32)
                    success := mload(0)        // Set `success = returndata` of external call
                }
                default {                     // This is an excessively non-compliant ERC-20, revert.
                    revert(0, 0)
                }
        }
        require(success, "TOKEN_TRANSFER_IN_FAILED");
        uint balanceAfter = IERC20(token_).balanceOf(address(this));
        require(balanceAfter <= balanceBefore, "TOKEN_TRANSFER_IN_OVERFLOW");
        return balanceBefore - balanceAfter;  // underflow already checked above, just subtract
    }

    /**
    * @notice The interface of IERC20 token withdrawn.
    * @dev Call doTransferOut, transfer token to owner.
    * @param token address.
    * @param amount uint256.
    * @return actualSubAmount.
    */
    function withdraw(address token, uint256 amount) internal returns (uint) {
        require(token != address(0), "TOKEN_CANT_BE_ZERO");
        require(IERC20(token).balanceOf(address(this)) >= amount, "NOT_ENOUGH_TOKEN");
        IERC20(token).approve(msg.sender, amount);
        uint256 actualSubAmount = doTransferOut(token, msg.sender, amount);
        emit Withdraw(msg.sender, token, actualSubAmount);
        return actualSubAmount;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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