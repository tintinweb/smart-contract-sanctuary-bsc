// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IDixelArt.sol";

/**
* @title DixelTip
*
* Crowd-sourced pixel art community
*/
contract DixelTip is Context {
    IERC20 public baseToken;
    IDixelArt public dixelArt;

    // tokenId -> tipAmount
    mapping(uint256 => uint96) private tokenTipAmount;

    event Tip(address indexed sender, uint256 indexed tokenId, uint96 tipAmount);
    event BurnAndRefundTips(address indexed player, uint256 indexed tokenId, uint96 tipAmount);

    constructor(address baseTokenAddress, address dixelArtAddress) {
        baseToken = IERC20(baseTokenAddress);
        dixelArt = IDixelArt(dixelArtAddress);
    }

    function tip(uint256 tokenId, uint96 tipAmount) external {
        require(tipAmount > 0, "TIP_AMOUNT_MUST_BE_POSITIVE");
        require(dixelArt.exists(tokenId), "CANNOT_TIP_ON_BURNED_TOKEN");

        address msgSender = _msgSender();

        require(baseToken.transferFrom(msgSender, address(this), tipAmount), "TIP_TRANSFER_FAILED");
        tokenTipAmount[tokenId] += tipAmount;

        emit Tip(msgSender, tokenId, tipAmount);
    }

    // NOTE: Should approve first - `dixelArt.approve(address(this), tokenId)`
    function burnAndRefundTips(uint256 tokenId) external {
        require(dixelArt.exists(tokenId), "TOKEN_HAS_ALREADY_BURNED");
        require(tokenTipAmount[tokenId] > 0, "NO_TIPS_JUST_USE_BURN_FUNCTION");

        require(dixelArt.getApproved(tokenId) == address(this), "CONTRACT_IS_NOT_APPROVED");

        address msgSender = _msgSender();
        address owner = dixelArt.ownerOf(tokenId);

        // NOTE: `dixelArt.burn` will check approvals for `address(this)` (caller = this contract)
        // so we need to check token approvals of msgSender here to prevent users from burning someone else's NFT
        require(msgSender == owner || dixelArt.isApprovedForAll(owner, msgSender), "CALLER_IS_NOT_APPROVED");

        // keep this before burning for later use
        uint96 toRefund = totalBurnValue(tokenId);
        tokenTipAmount[tokenId] = 0;

        // NOTE: will refund tokens to this contract
        dixelArt.burn(tokenId);
        require(!dixelArt.exists(tokenId), "TOKEN_BURN_FAILED"); // double check

        // Pay accumulated tips to the user in addition to "burn refund" amount
        require(baseToken.transfer(msgSender, toRefund), "TIP_REFUND_TRANSFER_FAILED");
    }

    // MARK: - Utility view functions

    function accumulatedTipAmount(uint256 tokenId) external view returns (uint96) {
        return tokenTipAmount[tokenId];
    }

    function updatedPixelCount(uint256 tokenId) external view returns (uint16 count) {
        (count,,) = dixelArt.history(tokenId);
    }

    function reserveFromMintingCost(uint256 tokenId) public view returns (uint96 reserve) {
        (,reserve,) = dixelArt.history(tokenId);
    }

    function totalBurnValue(uint256 tokenId) public view returns (uint96) {
        if (!dixelArt.exists(tokenId)) {
            return 0;
        }

        return tokenTipAmount[tokenId] + reserveFromMintingCost(tokenId);
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

pragma solidity ^0.8.10;

interface IDixelArt {
  function approve (address to, uint256 tokenId) external;
  function balanceOf (address owner) external view returns (uint256);
  function baseToken () external view returns (address);
  function burn (uint256 tokenId) external;
  function exists (uint256 tokenId) external view returns (bool);
  function generateBase64SVG (uint256 tokenId) external view returns (string memory);
  function generateJSON (uint256 tokenId) external view returns (string memory json);
  function generateSVG (uint256 tokenId) external view returns (string memory);
  function getApproved (uint256 tokenId) external view returns (address);
  function getPixelsFor (uint256 tokenId) external view returns (uint24[16][16] memory);
  function history (uint256) external view returns (uint16 updatedPixelCount, uint96 reserveForRefund, bool burned);
  function isApprovedForAll (address owner, address operator) external view returns (bool);
  function mint (address to, uint24[16][16] memory pixelColors, uint16 updatedPixelCount, uint96 reserveForRefund, uint96 totalPrice) external;
  function name () external view returns (string memory);
  function nextTokenId () external view returns (uint256);
  function owner () external view returns (address);
  function ownerOf (uint256 tokenId) external view returns (address);
  function renounceOwnership () external;
  function safeTransferFrom (address from, address to, uint256 tokenId) external;
  function safeTransferFrom (address from, address to, uint256 tokenId, bytes calldata data) external;
  function setApprovalForAll (address operator, bool approved) external;
  function supportsInterface (bytes4 interfaceId) external view returns (bool);
  function symbol () external view returns (string memory);
  function tokenByIndex (uint256 index) external view returns (uint256);
  function tokenOfOwnerByIndex (address owner, uint256 index) external view returns (uint256);
  function tokenURI (uint256 tokenId) external view returns (string memory);
  function totalSupply () external view returns (uint256);
  function transferFrom (address from, address to, uint256 tokenId) external;
  function transferOwnership (address newOwner) external;
}