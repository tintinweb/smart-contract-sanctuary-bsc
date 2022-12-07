// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MySanta is Ownable, ReentrancyGuard {
    enum Token {
        BUSD,
        USDT,
        USDC
    }

    struct Transfer {
        uint256 id;
        address sender;
        uint256 charityId;
        address receiver;
        uint256 amount;
        Token token;
        string note;
        uint256 transferTime;
        bool isPublic;
    }

    struct Donor {
        uint256 totalBUSDDonation;
        uint256 totalUSDTDonation;
        uint256 totalUSDCDonation;
        bool isPublic;
        mapping(uint256 => bool) followingCharity;
    }

    struct Charity {
        uint256 id;
        address owner;
        string name;
        string location;
        string website;
        string phone;
        string description;
        address fundReceiver;
        uint256 createdAt;
        uint256 updatedAt;
        uint256 numOfFollowers;
        bool isTaxDeductible;
        string taxId;
    }

    uint256 charityCount;

    uint256 transactionCount;

    // Map a donor's address to transfer structs
    mapping(address => Transfer[]) public contributions;

    // Map a charity id to transfer structs
    mapping(uint256 => Transfer[]) public charityDonations;

    // Map a donor's address to donor struct
    mapping(address => Donor) public donor;

    // Map a charity id to charity structs
    mapping(uint256 => Charity) public charity;

    Transfer[] transactions;

    IERC20 public immutable busd;
    IERC20 public immutable usdt;
    IERC20 public immutable usdc;

    uint256 public developmentFee = 18; // 1.8%
    uint256 public daoFee = 2; // 0.2%
    uint256 public totalFee = 20; // 1.5%
    uint256 public feeDenominator = 1000;

    address public developmentFeeReceiver;
    address public daoFeeReceiver;

    event AddCharity(
        address owner,
        string name,
        string location,
        string website,
        string phone,
        string description,
        address fundReceiver,
        uint256 createdAt,
        uint256 updatedAt,
        bool isTaxDeductible,
        string taxId
    );

    event MakeTransfer(
        address sender,
        uint256 charityId,
        address receiver,
        uint256 amount,
        Token token,
        string note,
        uint256 transferTime,
        bool isPublic
    );

    event SetIsPublic(bool isPublic);

    event FollowCharity(uint256 charityId);

    event UnfollowCharity(uint256 charityId);

    receive() external payable {}

    constructor() {
        busd = IERC20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);
        usdt = IERC20(0x377533D0E68A22CF180205e9c9ed980f74bc5050);
        usdc = IERC20(0x3Fc54ADd69955724169E9aB22D59152320811327);

        developmentFeeReceiver = 0xB9C2A343Df040F38cff43af1Fa826B76b1F6F43E;
        daoFeeReceiver = 0xC8F577F5FB6C4a2ae6387d5269F211a36AcaCbF7;
    }

    function addCharity(
        address owner,
        string memory name,
        string memory location,
        string memory website,
        string memory phone,
        string memory description,
        address payable fundReceiver,
        bool isTaxDeductible,
        string memory taxId
    ) external onlyOwner {
        charityCount += 1;
        charity[charityCount] = Charity(
            charityCount,
            owner,
            name,
            location,
            website,
            phone,
            description,
            fundReceiver,
            block.timestamp,
            block.timestamp,
            0,
            isTaxDeductible,
            taxId
        );

        emit AddCharity(
            owner,
            name,
            location,
            website,
            phone,
            description,
            fundReceiver,
            block.timestamp,
            block.timestamp,
            isTaxDeductible,
            taxId
        );
    }

    function getAllTransactions() external view returns (Transfer[] memory) {
        return transactions;
    }

    function getContributions(address _donor)
        external
        view
        returns (Transfer[] memory)
    {
        return contributions[_donor];
    }

    function getCharity(uint256 chainId)
        external
        view
        returns (Charity memory)
    {
        return charity[chainId];
    }

    function getCharityDonations(uint256 chainId)
        external
        view
        returns (Transfer[] memory)
    {
        return charityDonations[chainId];
    }

    function getTransactionCount() external view returns (uint256) {
        return transactionCount;
    }

    function setIsPublic(bool isPublic) external returns (bool) {
        donor[msg.sender].isPublic = isPublic;

        emit SetIsPublic(isPublic);
        return isPublic;
    }

    function followCharity(uint256 charityId) external returns (uint256) {
        require(charity[charityId].id != 0, "My Santa: charity does not exist");
        require(
            !donor[msg.sender].followingCharity[charityId],
            "My Santa: already follow"
        );
        donor[msg.sender].followingCharity[charityId] = true;
        charity[charityId].numOfFollowers += 1;

        emit FollowCharity(charityId);
        return charityId;
    }

    function unfollowCharity(uint256 charityId) external returns (uint256) {
        require(charity[charityId].id != 0, "My Santa: charity does not exist");
        require(
            donor[msg.sender].followingCharity[charityId],
            "My Santa: already unfollow"
        );
        donor[msg.sender].followingCharity[charityId] = false;
        charity[charityId].numOfFollowers -= 1;

        emit UnfollowCharity(charityId);
        return charityId;
    }

    function transfer(
        uint256 charityId,
        uint256 amount,
        Token token,
        string memory note,
        bool isPublic
    ) external {
        Charity memory _charity = charity[charityId];
        address receiver = _charity.fundReceiver;
        require(receiver != address(0), "My Santa: no available charity");
        require(amount > 0, "My Santa: amount should be greater than one");

        uint256 developmentFeeAmount = (amount * developmentFee) /
            feeDenominator;
        uint256 daoFeeAmount = (amount * daoFee) / feeDenominator;
        uint256 feeAmount = (amount * totalFee) / feeDenominator;
        uint256 amountReceived = amount - feeAmount;

        if (token == Token.BUSD) {
            busd.transferFrom(msg.sender, receiver, amountReceived);
            busd.transferFrom(
                msg.sender,
                developmentFeeReceiver,
                developmentFeeAmount
            );
            busd.transferFrom(msg.sender, daoFeeReceiver, daoFeeAmount);

            donor[msg.sender].totalBUSDDonation = amount;
        } else if (token == Token.USDT) {
            usdt.transferFrom(msg.sender, receiver, amountReceived);
            usdt.transferFrom(
                msg.sender,
                developmentFeeReceiver,
                developmentFeeAmount
            );
            usdt.transferFrom(msg.sender, daoFeeReceiver, daoFeeAmount);

            donor[msg.sender].totalUSDTDonation = amount;
        } else if (token == Token.USDC) {
            usdc.transferFrom(msg.sender, receiver, amountReceived);
            usdc.transferFrom(
                msg.sender,
                developmentFeeReceiver,
                developmentFeeAmount
            );
            usdc.transferFrom(msg.sender, daoFeeReceiver, daoFeeAmount);

            donor[msg.sender].totalUSDCDonation = amount;
        } else {
            revert("Not supporting token");
        }

        transactionCount += 1;
        Transfer memory transferObj = Transfer(
            transactionCount,
            msg.sender,
            charityId,
            receiver,
            amount,
            token,
            note,
            block.timestamp,
            isPublic
        );

        transactions.push(transferObj);
        charityDonations[charityId].push(transferObj);
        contributions[msg.sender].push(transferObj);

        emit MakeTransfer(
            msg.sender,
            charityId,
            receiver,
            amount,
            token,
            note,
            block.timestamp,
            isPublic
        );
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