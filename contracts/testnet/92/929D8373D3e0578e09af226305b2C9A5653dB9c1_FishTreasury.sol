// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FishTreasury is
    Context,
    Ownable,
    ReentrancyGuard
{
    using SafeMath for uint256;

    event ClaimNFT(
        address indexed minter,
        uint256 amount,
        string priceID,
        uint256 FishNFTId
    );

    event SwapDiamond(
        address indexed swapper,
        uint256 amountInLFW,
        uint256 amountInDiamond,
        uint256 serverId,
        string priceID
    );

    event ConversionRateChange(uint256 conversionRate);
    event FixGun(address indexed user, string priceID, uint256 tokenId);

    // Whitelisted for beta testing
    bool public betaWhitelisted;

    // Use BNB or token to buy box
    bool public isUsedBNB;

    // Mapping whitelisted for beta testing
    mapping(address => bool) isWhitelisted;

    // Amount used to fix gun
    uint256 public amountToFixGun;

    // Fish treasury wallet address
    address public treasuryWallet;

    // Reward wallet address;
    address public rewardWallet;

    // lfw token
    IERC20 public lfwToken;

    // Is initilize the contract yet
    bool public isInitialized;

    // convert token to diamond by formular diamond = token*conversionRate
    uint256 public conversionRate;

    // Number of total NFT Minted in each box
    mapping(uint256 => uint256) public totalMintedNFT;

    // Nonce for random
    uint256 private nonce;

    // NFTIds in each box
    mapping(uint256 => uint256[]) public NFTIds;

    // Allow contract to receive ether
    receive() external payable {}

    /**
     * @notice config external SC address for this SC
     * @dev only call by owner
     * @param _treasuryWallet: address of treasury wallet to transfer fund
     * @param _rewardWallet: reward pool SC to reward user in game
     * @param _lfwToken: lfw token address
     * @param _isUsedBNB: use BNB or token to buy box 
     */
    function configSC(
        address _treasuryWallet,
        address _rewardWallet,
        address _lfwToken,
        bool _isUsedBNB
    )
        public
        onlyOwner
    {
        require(!isInitialized, "FishTreasury: Already initialized");
        require(address(_treasuryWallet) != address(0), "Invalid FishTreasury wallet address");
        require(address(_rewardWallet) != address(0), "Invalid rewardSC address");
        require(address(_lfwToken) != address(0), "Invalid LFWToken address");
        isInitialized = true;
        treasuryWallet = _treasuryWallet;
        rewardWallet = _rewardWallet;
        lfwToken = IERC20(_lfwToken);
        isUsedBNB = _isUsedBNB;
    }

    /**
     * @notice whitelist address to play in beta game
     * @dev only call by owner
     * @param _addresses: list of whitelisted addresses
     */
    function addWhitelistAddresses(
        address[] memory _addresses
    ) external onlyOwner {
        require(isInitialized, "Pool is not initialized");
        for (uint256 index = 0; index < _addresses.length; index++) {
            isWhitelisted[_addresses[index]] = true;
        }
    }


    /**
     * @notice remove whitelist address
     * @dev only call by owner
     * @param _addresses: list of whitelisted addresses
     */
    function removeWhitelistAddresses(
        address[] memory _addresses
    ) external onlyOwner {
        require(isInitialized, "Pool is not initialized");
        for (uint256 index = 0; index < _addresses.length; index++) {
            isWhitelisted[_addresses[index]] = false;
        }
    }


    /**
     * @notice set beta whitelisted
     * @dev only call by owner
     * @param _betaWhitelisted: true or false
     */
    function setBetaWhitelisted(bool _betaWhitelisted) public onlyOwner {
        betaWhitelisted = _betaWhitelisted;
    }

    /**
     * @notice set new fish treasury wallet
     * @dev only call by owner
     * @param _treasuryWallet: address of treasury wallet to transfer fund
     */
    function setTreasuryWallet(address _treasuryWallet) public onlyOwner {
        treasuryWallet = _treasuryWallet;
    }

    /**
     * @notice set new reward SC
     * @dev only call by owner
     * @param _rewardWallet: reward wallet to reward user in game
     */
    function setRewardWallet(address _rewardWallet) public onlyOwner {
        rewardWallet = _rewardWallet;
    }

    /**
     * @notice set new lfw token address
     * @dev only call by owner
     * @param _lfwToken: lfw token address
     */
    function setLfwToken(address _lfwToken) public onlyOwner {
        lfwToken = IERC20(_lfwToken);
    }

    /**
     * @notice set bnb amount needed to fix gun
     * @dev only call by owner
     * @param _amount: amount needed to fix gun
     */
    function setAmountToFixGuns(uint256 _amount) public onlyOwner {
        require(_amount != 0, "FishTreasury: Parameter must not be 0");
        amountToFixGun = _amount;
    }


    /**
     * @notice update list token id of NFT reward in each box
     * @dev only call by owner
     * @param _boxNumber: box number
     * @param _startId: start token id
     * @param _endId: end token id
     */
    function addNFTsIntoBoxByTokenIdRange(
        uint256 _boxNumber, 
        uint256 _startId, 
        uint256 _endId
    ) external onlyOwner {
        for ( uint256 tokenId = _startId;  tokenId <= _endId; tokenId++) {
            NFTIds[_boxNumber].push(tokenId);
        }
    }

    /**
     * @notice update list token id of NFT reward in each box
     * @dev only call by owner
     * @param _boxNumber: box number
     * @param _tokenIds: list of token Ids
     */
    function addNFTsIntoBox(
        uint256 _boxNumber, 
        uint256[] memory _tokenIds
    ) external onlyOwner {
        for (uint256 index = 0; index < _tokenIds.length; index++) {
            NFTIds[_boxNumber].push(_tokenIds[index]);
        }
    }

    /**
     * @notice set conversion rate of LFW and Diamond
     * @dev only call by owner
     * @param _rate: conversion rate number
     */
    function setConversionRate(uint256 _rate) external onlyOwner {
        conversionRate = _rate;
        emit ConversionRateChange(conversionRate);
    }

    /**
     * @notice swap token to diamond, transfer token to treasury wallet
     * @dev only call by owner
     * @param _amount: amount used to buy diamond
     * @param _serverId: sever ID that user want to transfer diamond in
     * @param _tokenAddress: Use which token address to swap diamond
     * @param _priceID: priceID for backend verification
     */
    function swapDiamond(
        uint256 _amount,
        uint256 _serverId,
        address _tokenAddress,
        string memory _priceID
    ) external nonReentrant returns (uint256){
        IERC20 tokenAddress = IERC20(_tokenAddress);

        require(
            _amount > 0, 
            "Invalid number"
        );

        uint256 balance = tokenAddress.balanceOf(_msgSender());

        require(
            balance >= _amount, 
            "Insufficient token in your wallet"
        );

        tokenAddress.transferFrom(_msgSender(), address(treasuryWallet), _amount);

        uint256 diamondAmount = _amount.mul(conversionRate);

        // game will handle diamond.div(conversionRate)
        emit SwapDiamond(_msgSender(), _amount, diamondAmount, _serverId, _priceID);

        return diamondAmount;
    }

    /**
     * @notice mint NFT in each box
     * @dev only call by owner
     * @param _boxNumber: box number that user want to mint
     * @param _tokenAddress: token used to buy box
     * @param _priceID: priceID for backend verification
     * @param _amount: amount used to buy box
     */
    function mintNFT(
        uint256 _boxNumber,
        address _tokenAddress,
        string memory _priceID,
        uint256 _amount
    ) external payable nonReentrant {
        IERC20 tokenAddress = IERC20(_tokenAddress);
        address _receipient = _msgSender();

        if (betaWhitelisted) {
            require(
                isWhitelisted[_receipient],
                "You need to be whitelisted to test the beta game"
            );
        }

        require(
            NFTIds[_boxNumber].length > 0, 
            "Run out of NFT"
        );

        // Mint NFTs
        uint256 randomSlot = random(0, NFTIds[_boxNumber].length);
        uint256 fishNFTId = NFTIds[_boxNumber][randomSlot];
        totalMintedNFT[_boxNumber] = totalMintedNFT[_boxNumber].add(1);

        // Remove NFT out of NFTIds array
        NFTIds[_boxNumber][randomSlot] = 
            NFTIds[_boxNumber][NFTIds[_boxNumber].length - 1];
        NFTIds[_boxNumber].pop();

        // "call" method in combination with re-entrancy guard is the recommended
        // method to use after December 2019.
        if (isUsedBNB) {
            (bool sent, ) = payable(rewardWallet).call{value: _amount}("");
            require(sent, "Failed to send Ether");  
        } else {
            tokenAddress.transferFrom(
                _msgSender(), 
                address(rewardWallet), 
                _amount
            );
        }

        emit ClaimNFT(_receipient, _amount, _priceID, fishNFTId);
    }

    /**
     * @notice fix gun using BNB
     * @param _tokenId: token Id of gun that user want to fix
     * @param _priceID: priceID for backend verification
     */
    function fixGun(
        uint256 _tokenId,
        string memory _priceID,
        address _tokenAddress
    ) external payable nonReentrant {
        IERC20 tokenAddress = IERC20(_tokenAddress);
        if (isUsedBNB) {
            payable(treasuryWallet).transfer(amountToFixGun);
        } else {
            tokenAddress.transferFrom(
                _msgSender(), 
                address(treasuryWallet), 
                amountToFixGun
            );
        }
        emit FixGun(_msgSender(), _priceID, _tokenId);
    }


    /**
     * @dev generate a random number
     * @param min min number include
     * @param max max number exclude
     */
    function random(uint256 min, uint256 max)
        internal
        returns (uint256 randomnumber)
    {
        randomnumber = uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))
        ).mod(max - min);
        randomnumber = randomnumber + min;
        nonce = nonce.add(1);
        return randomnumber;
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