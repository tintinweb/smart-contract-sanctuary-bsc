// SPDX-License-Identifier: MIT

pragma solidity =0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./FeeCollectorStorage.sol";


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

interface IERC721 {

    /**
  * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    function firstHolder(uint256 tokenId) external view returns(address);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);
}


contract FeeCollector is FeeCollectorStorage, ReentrancyGuard, Ownable{

    event SetFeeRatio(uint256 oldFeeRatio, uint256 newFeeRatio);
    event SetCapitalPool(address oldCapitalPool, address newCapitalPool);
    event SetTechnicalSupport(address oldTechnicalSupport, address newTechnicalSupport);
    event SetTrade(address oldTrade, address newTrade);
    event NFTHolderFee(address token, uint256 id, address owner, uint256 royalty);
    event PoolFeeWithdraw(address token, uint256 fee);
    event TechnologyFeeWithdraw(address token, uint256 fee);
    event WithdrawFee(address token, uint256 totalAvailable, uint256 available);
    event MultipleWithdrawFee(address token, uint256 totalReceive);

    using SafeMath for uint256;

    constructor(address _capitalPool, address _technicalSupport, uint256 _feeRatio){
        capitalPool = _capitalPool;
        technicalSupport = _technicalSupport;
        feeRatio = _feeRatio;
    }


    function serviceCharge(address offerToken, uint256 identifier, address quoteToken, uint256 quoteAmount) external onlyTrade returns(address, uint256, address, uint256){
        address nftHolder = IERC721(offerToken).firstHolder(identifier);
        require(nftHolder != address(0), "The address of the first NFT holder does not exist");

        uint256 fee = quoteAmount.mul(1e18).div(feeRatio);

        uint256 holderFee = fee.mul(holderFeeRatio).div(1e18);
        uint256 poolFeeDividend = fee.mul(capitalPoolFeeRatio).div(1e18);
        // technicalSupportFee += fee.mul(technicalSupportFeeRatio).div(1e18);
        uint256 genesisDividend = fee.mul(genesisFeeRatio).div(1e18);
        uint256 jointDividend = fee.mul(jointFeeRatio).div(1e18);

        uint256 feeSum = holderFee.add(poolFeeDividend).add(genesisDividend).add(jointDividend);
        technicalSupportFee += quoteAmount.sub(feeSum);

        capitalPoolFee += poolFeeDividend;
        totalNftFee[genesis] += genesisDividend;
        totalNftFee[joint] += jointDividend;

        totalAmount += quoteAmount;

        IERC20(quoteToken).transfer(nftHolder, holderFee);
        emit NFTHolderFee(offerToken, identifier, nftHolder, holderFee);
        return (offerToken, identifier, quoteToken, quoteAmount);
    }

    function poolFeeWithdraw() external returns(address, uint256){
        require(msg.sender == capitalPool, "The caller is not the fund pool address");
        bool success = IERC20(quoteToken).transfer(msg.sender, capitalPoolFee);
        if(success) capitalPoolFee = 0;
        emit PoolFeeWithdraw(quoteToken, capitalPoolFee);
        return (quoteToken, capitalPoolFee);
    }

    function technologyFeeWithdraw() external returns(address, uint256){
        require(msg.sender == technicalSupport, "The caller is not a technical support address");
        bool success = IERC20(quoteToken).transfer(msg.sender, technicalSupportFee);
        if(success) technicalSupportFee = 0;
        emit TechnologyFeeWithdraw(quoteToken, technicalSupportFee);
        return (quoteToken, technicalSupportFee);
    }

    function withdrawFee(address nft, uint256 tokenId) external nonReentrant returns(address, uint256, uint256){
        address owner = IERC721(nft).ownerOf(tokenId);
        require(owner == msg.sender, "This NFT card is not yours");

        uint256 totalSupply = IERC721(nft).totalSupply();
        uint256 dividend = totalNftFee[nft].div(totalSupply);

        uint256 received = receivedFee[nft][tokenId];
        uint256 fundsAvailable = dividend.sub(received);
        require(fundsAvailable > 0, "No handling fee dividends to be claimed");

        bool success = IERC20(quoteToken).transfer(msg.sender, fundsAvailable);
        if(success) receivedFee[nft][tokenId] += fundsAvailable;
        emit WithdrawFee(quoteToken, dividend, fundsAvailable);
        return (quoteToken, dividend, fundsAvailable);
    }

    function multipleWithdrawFee(address[] calldata nft, uint256[] calldata tokenId) external nonReentrant returns(bool){
        require(nft.length > 0, "NFT array length is less than 0");
        uint256 _totalAmount;
        for(uint i; i < nft.length; i++){
            address owner = IERC721(nft[i]).ownerOf(tokenId[i]);
            require(owner == msg.sender, "This NFT card is not yours");

            uint256 totalSupply = IERC721(nft[i]).totalSupply();
            uint256 dividend = totalNftFee[nft[i]].div(totalSupply);

            uint256 received = receivedFee[nft[i]][tokenId[i]];
            uint256 fundsAvailable = dividend.sub(received);
            _totalAmount += fundsAvailable;
            receivedFee[nft[i]][tokenId[i]] += fundsAvailable;
        }
        bool success = IERC20(quoteToken).transfer(msg.sender, _totalAmount);

        emit MultipleWithdrawFee(quoteToken, _totalAmount);
        return success;
    }

    function _setFeeRatio(uint256 newFeeRatio) external onlyOwner {
        require(newFeeRatio > 0, "Parameter error");
        uint256 old = feeRatio;
        feeRatio = newFeeRatio;
        emit SetFeeRatio(old, newFeeRatio);
    }

    function _setHolderFeeRatio(uint256 newHolderFeeRatio) external onlyOwner {
        require(newHolderFeeRatio > 0, "Parameter error");
        uint256 old = holderFeeRatio;
        holderFeeRatio = newHolderFeeRatio;
        emit SetFeeRatio(old, newHolderFeeRatio);
    }

    function _setCapitalPoolFeeRatio(uint256 newCapitalPoolFeeRatio) external onlyOwner {
        require(newCapitalPoolFeeRatio > 0, "Parameter error");
        uint256 old = capitalPoolFeeRatio;
        capitalPoolFeeRatio = newCapitalPoolFeeRatio;
        emit SetFeeRatio(old, newCapitalPoolFeeRatio);
    }

    function _setTechnicalSupportFeeRatio(uint256 newTechnicalSupportFeeRatio) external onlyOwner {
        require(newTechnicalSupportFeeRatio > 0, "Parameter error");
        uint256 old = technicalSupportFeeRatio;
        technicalSupportFeeRatio = newTechnicalSupportFeeRatio;
        emit SetFeeRatio(old, newTechnicalSupportFeeRatio);
    }

    function _setGenesisFeeRatio(uint256 newGenesisFeeRatio) external onlyOwner {
        require(newGenesisFeeRatio > 0, "Parameter error");
        uint256 old = genesisFeeRatio;
        genesisFeeRatio = newGenesisFeeRatio;
        emit SetFeeRatio(old, newGenesisFeeRatio);
    }

    function _setJointFeeRatio(uint256 newJointFeeRatio) external onlyOwner {
        require(newJointFeeRatio > 0, "Parameter error");
        uint256 old = jointFeeRatio;
        jointFeeRatio = newJointFeeRatio;
        emit SetFeeRatio(old, newJointFeeRatio);
    }

    function _setCapitalPool(address newCapitalPool) external onlyOwner {
        require(newCapitalPool != address(0), "Capital Pool cannot be set to zero address");
        address old = capitalPool;
        capitalPool = newCapitalPool;
        emit SetCapitalPool(old, newCapitalPool);
    }

    function _setTechnicalSupport(address newTechnicalSupport) external onlyOwner {
        require(newTechnicalSupport != address(0), "Technical Support cannot be set to zero address");
        address old = technicalSupport;
        technicalSupport = newTechnicalSupport;
        emit SetTechnicalSupport(old, newTechnicalSupport);
    }

    function _setTrade(address newTrade) external onlyOwner {
        require(newTrade != address(0), "Trade cannot be set to zero address");
        address old = trade;
        trade = newTrade;
        emit SetTrade(old, newTrade);
    }

    function amountAvailable(address nft, uint256 tokenId) external view returns(uint256) {
        uint256 totalSupply = IERC721(nft).totalSupply();
        uint256 dividend = totalNftFee[nft].div(totalSupply);
        uint256 received = receivedFee[nft][tokenId];
        uint256 fundsAvailable = dividend.sub(received);
        return fundsAvailable;
    }

    function amountAvailableList(address[] calldata nft, uint256[] calldata tokenId) external view returns(address[] memory, uint256[] memory, uint256[] memory) {
        uint256[] memory total = new uint256[](nft.length);
        for(uint i; i < nft.length; i++){
            uint256 totalSupply = IERC721(nft[i]).totalSupply();
            uint256 dividend = totalNftFee[nft[i]].div(totalSupply);
            uint256 received = receivedFee[nft[i]][tokenId[i]];
            uint256 fundsAvailable = dividend.sub(received);
            total[i] = fundsAvailable;
        }
        return (nft, tokenId, total);
    }

    function balanceOf() external view returns(uint256) {
        return IERC20(quoteToken).balanceOf(address(this));
    }

    modifier onlyTrade(){
        require(msg.sender == trade, "caller is not the trade address");
        _;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.16;


contract FeeCollectorStorage {

    address public trade;
    address public constant quoteToken = 0x55d398326f99059fF775485246999027B3197955;

    uint256 public feeRatio;
    uint256 public holderFeeRatio;
    uint256 public capitalPoolFeeRatio;
    uint256 public technicalSupportFeeRatio;
    uint256 public genesisFeeRatio;
    uint256 public jointFeeRatio;

    address public capitalPool;
    uint256 public capitalPoolFee;

    address public technicalSupport;
    uint256 public technicalSupportFee;

    address public constant genesis = 0x15b8054314A5a9D34728367327c40b72405c1Bc8;
    address public constant joint = 0x2C1Ca7068914B3cA2982955B354629506E8b2D2E;

    mapping(address => uint256) public totalNftFee;

    mapping(address => mapping(uint256 => uint256)) public receivedFee;

    uint256 public totalAmount;
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