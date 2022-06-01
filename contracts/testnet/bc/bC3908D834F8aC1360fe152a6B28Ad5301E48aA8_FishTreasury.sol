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
        uint256 FishTokenId
    );
    event SwapDiamond(
        address indexed swapper,
        uint256 amountInLFW,
        uint256 amountInDiamond,
        uint256 serverId
    );
    event ConversionRateChange(uint256 newConversion);
    event FixGun(address indexed user, uint256 tokenId);

    // Base price for minting NFTs for each box
    mapping(uint256 => uint256) public basePrice;

    // Bnb needed to fix gun
    uint256 public bnbToFixGun;
    
    // Fish treasury wallet address
    address public fishTreasuryWallet;

    // LFW treasury wallet address
    address public lfwTreasuryWallet;

    // Reward smart contract address;
    address public rewardSC;

    // lfw token
    IERC20 public lfwToken;

    // Is initilize the contract yet
    bool public isInitialized;

    // convert lfwtoken to diamond by formular diamond = lfwtoken*conversionRate
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
     * @param _fishTreasuryWallet: address of treasury wallet to transfer fund
     * @param _lfwTreasuryWallet: lfw treasury wallet that we already used in LFWar game
     * @param _rewardSC: reward pool SC to reward user in game
     * @param _lfwToken: lfw token address
     */
    function configSC(
        address _fishTreasuryWallet,
        address _lfwTreasuryWallet,
        address _rewardSC,
        address _lfwToken
    )
        public
        onlyOwner
    {
        require(!isInitialized, "Already initialized");
        require(address(_fishTreasuryWallet) != address(0), "Invalid address");
        require(address(_lfwTreasuryWallet) != address(0), "Invalid address");
        require(address(_rewardSC) != address(0), "Invalid address");
        require(address(_lfwToken) != address(0), "Invalid address");
        isInitialized = true;
        fishTreasuryWallet = _fishTreasuryWallet;
        lfwTreasuryWallet = _lfwTreasuryWallet;
        rewardSC = _rewardSC;
        lfwToken = IERC20(_lfwToken);
    }


    /**
     * @notice set new fish treasury wallet
     * @dev only call by owner
     * @param _fishTreasuryWallet: address of treasury wallet to transfer fund
     */
    function setNewFishTreasuryWallet(address _fishTreasuryWallet) public onlyOwner {
        fishTreasuryWallet = _fishTreasuryWallet;
    }

    /**
     * @notice set new lfw treasury wallet
     * @dev only call by owner
     * @param _lfwTreasuryWallet: lfw treasury wallet that we already used in LFWar game
     */
    function setNewLfwTreasuryWallet(address _lfwTreasuryWallet) public onlyOwner {
        lfwTreasuryWallet = _lfwTreasuryWallet;
    }

    /**
     * @notice set new reward SC
     * @dev only call by owner
     * @param _rewardSC: reward pool SC to reward user in game
     */
    function setNewRewardSC(address _rewardSC) public onlyOwner {
        rewardSC = _rewardSC;
    }

    /**
     * @notice set new lfw token address
     * @dev only call by owner
     * @param _lfwToken: lfw token address
     */
    function setNewLfwToken(address _lfwToken) public onlyOwner {
        lfwToken = IERC20(_lfwToken);
    }

    /**
     * @notice set base price for minting NFT at each box
     * @dev only call by owner
     * @param _boxNumber: box number, i.e., 1, 2, etc.
     * @param _price: base price for each box
     */
    function setBasePrice(
        uint256 _boxNumber,
        uint256 _price
    )
        public
        onlyOwner
    {
        require(
            _boxNumber != 0 && _price !=0,
             "Invalid number"
        );

        basePrice[_boxNumber] = _price;
    }

    /**
     * @notice set bnb amount needed to fix gun
     * @dev only call by owner
     * @param _bnbAmount: base price for each box
     */
    function setBnbToFixGun(uint256 _bnbAmount) public onlyOwner {
        require(
            _bnbAmount != 0,
            "Invalid number"
        );

        bnbToFixGun = _bnbAmount;
    }


    /**
     * @notice update list token id of NFT reward in each box
     * @dev only call by owner
     * @param _boxNumber: box number
     * @param _startId: start token id
     * @param _endId: end token id
     */
    function updateNftTokenIds(
        uint256 _boxNumber,
        uint256 _startId,
        uint256 _endId
    ) external onlyOwner {
        for (
            uint256 tokenId = _startId;
            tokenId <= _endId;
            tokenId++
        ) {
            NFTIds[_boxNumber].push(tokenId);
        }
    }

    /**
     * @notice update list token id of NFT reward in each box
     * @dev only call by owner
     * @param _boxNumber: box number 
     * @param _tokenId: list of token Id
     */
    function updateNftTokenIdsOthersWay(
        uint256 _boxNumber,
        uint256[] memory _tokenId
    ) external onlyOwner {
        for (
            uint256 index = 0;
            index < _tokenId.length;
            index++
        ) {
            NFTIds[_boxNumber].push(_tokenId[index]);
        }
    }


    /**
     * @notice set conversion rate of LFW and Diamond
     * @dev only call by owner
     * @param _newConversion: conversion rate number
     */
    function setConversionRate(
        uint256 _newConversion
    ) external onlyOwner {
        conversionRate = _newConversion;
        emit ConversionRateChange(_newConversion);
    }

    /**
     * @notice swap lfwtoken to diamond, transfer lfwtoken to lfw treasury wallet
     * @dev only call by owner
     * @param _amount: lfw amount used to buy diamond
     * @param _serverId: sever ID that user want to transfer diamond in
     */
    function swapDiamond(
        uint256 _amount, 
        uint256 _serverId
    ) external nonReentrant {
        require(_amount > 0, "Invalid number");

        uint256 balance = lfwToken.balanceOf(_msgSender());

        require(
            balance >= _amount, 
            "You do not have enough LFW Token"
        );

        lfwToken.transferFrom(msg.sender, address(lfwTreasuryWallet), _amount);

        // game will handle diamond.div(conversionRate)
        emit SwapDiamond(msg.sender, _amount, _amount.mul(conversionRate), _serverId);
    }

    /**
     * @notice mint NFT in each box
     * @dev only call by owner
     * @param _boxNumber: box number that user want to mint
     */
    function mintNFT(uint256 _boxNumber) external payable nonReentrant {
        require(
            NFTIds[_boxNumber].length > 0, 
            "Run out of NFT"
        );

        // base bnb for each box number
        uint256 bnbToTransfer = basePrice[_boxNumber];

        // Mint NFTs
        address _receipient = _msgSender();
        uint256 randomSlot = random(0, NFTIds[_boxNumber].length);
        uint256 heroId = NFTIds[_boxNumber][randomSlot];
        totalMintedNFT[_boxNumber] = totalMintedNFT[_boxNumber].add(1);

        // Remove NFT out of NFTIds array
        NFTIds[_boxNumber][randomSlot] = NFTIds[_boxNumber][
            NFTIds[_boxNumber].length - 1
        ];
        NFTIds[_boxNumber].pop(); 

        payable(rewardSC).transfer(bnbToTransfer);

        emit ClaimNFT(_receipient, heroId);
    }

    /**
     * @notice fix gun using BNB
     * @param _tokenId: token Id of gun that user want to fix
     */
    function fixGun(
        uint256 _tokenId
    ) external payable nonReentrant {
        payable(fishTreasuryWallet).transfer(bnbToFixGun);
        emit FixGun(_msgSender(), _tokenId);
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