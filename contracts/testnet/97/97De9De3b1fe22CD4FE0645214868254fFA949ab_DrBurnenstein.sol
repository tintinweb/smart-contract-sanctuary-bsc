// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
    constructor()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IPriceConsumerV3 {
    function getLatestPrice() external view returns (uint);
    function unlockFeeInBnb(uint) external view returns (uint);
    function usdToBnb(uint) external view returns (uint);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IRugZombieNft {
    function totalSupply() external view returns (uint256);
    function reviveRug(address _to) external returns(uint);
    function transferOwnership(address newOwner) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external returns (bool);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
    function owner() external view returns (address);
    function approve(address to, uint256 tokenId) external;
    function balanceOf(address _owner) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library Percentages {
    // Get value of a percent of a number
    function calcPortionFromBasisPoints(uint _amount, uint _basisPoints) public pure returns(uint) {
        if(_basisPoints == 0 || _amount == 0) {
            return 0;
        } else {
            uint _portion = _amount * _basisPoints / 10000;
            return _portion;
        }
    }

    // Get basis points (percentage) of _portion relative to _amount
    function calcBasisPoints(uint _amount, uint  _portion) public pure returns(uint) {
        if(_portion == 0 || _amount == 0) {
            return 0;
        } else {
            uint _basisPoints = (_portion * 10000) / _amount;
            return _basisPoints;
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.4;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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

pragma solidity ^0.8.4;

/*
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

    function _msgData() internal view virtual returns ( bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
     * by making the `nonReentrant` function external, and make it call a
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

pragma solidity ^0.8.4;

import "../includes/access/Ownable.sol";
import "../includes/libraries/Percentages.sol";
import "../includes/token/BEP20/IBEP20.sol";
import "../includes/interfaces/IUniswapV2Router02.sol";
import "../includes/interfaces/IPriceConsumerV3.sol";
import "../includes/interfaces/IRugZombieNft.sol";
import "../includes/utils/ReentrancyGuard.sol";

contract DrBurnenstein is Ownable, ReentrancyGuard {
    using Percentages for uint256;

    enum DepositType {
        NONE,
        TOKEN,
        NFT
    }

    struct UserInfo {
        uint256 amount;             // How many tokens are staked
        bool    deposited;          // Flag for if the required NFT/token has been deposited
        uint256 nftMintDate;        // The date the NFT is available to mint
        uint256 depositedAmount;    // The amount of the required tokens that were deposited
        uint    depositedId;        // The token ID of the deposited NFT
        uint256 burnedAmount;       // The amount of zombie that has been burned this minting cycle
    }

    struct GraveInfo {
        bool            isEnabled;          // Flag for it the grave is active
        IBEP20          stakingToken;       // The token to be staked
        DepositType     depositType;        // The type of required deposit
        address         deposit;            // The NFT/token that needs to be deposited
        IRugZombieNft   rewardNft;          // The NFT that gets rewarded by the grave
        uint256         minimumStake;       // The minimum amount of tokens that need to be staked
        uint256         mintingTime;        // The time it takes to mint the reward NFT
        uint256         burnTokens;         // The number of tokens that get burned when supply is low
        uint            burnHours;          // How many hours to take off the mint timer during a burn
        uint256         maxBurned;          // The maximum amount that can be burned per minting cycle
        uint256         totalStaked;        // The total tokens staked in a grave
        uint256         totalBurned;        // The total amount of ZMBE burned in this grave
    }

    IBEP20              public  zombie;         // The ZMBE token
    GraveInfo[]         public  graveInfo;      // Array of the pool structs
    address             payable treasury;       // Wallet address for the treasury

    // Mapping of user info to address mapped to each pool
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    // Address to send burned tokens to
    address public burnAddr = 0x000000000000000000000000000000000000dEaD;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event MintNft(address indexed to, uint date, address nft, uint indexed id);
    event ZombieBurned(address indexed user, uint grave, uint date, uint256 amount);

    // Constructor for constructing things
    constructor(
        address _zombie,
        address _treasury
    ) {
        zombie = IBEP20(_zombie);
        treasury = payable(_treasury);
    }

    // Modifier to ensure a user is staked in a grave
    modifier isStaked(uint _gid) {
        require(userInfo[_gid][msg.sender].amount > 0, 'Grave: You are not staked in this grave');
        _;
    }

    // Modifier to ensure grave has been unlocked
    modifier isUnlocked(uint _gid) {
        UserInfo memory user = userInfo[_gid][msg.sender];
        GraveInfo memory grave = graveInfo[_gid];
        require(user.deposited || grave.depositType == DepositType.NONE, 'Locked: Have not made the required deposit');
        _;
    }

    // Modifier to ensure user had made required deposit
    modifier hasDeposited(uint _gid) {
        require(userInfo[_gid][msg.sender].deposited || graveInfo[_gid].depositType == DepositType.NONE, 'Locked: Have not made the required deposit');
        _;
    }

    // Modifier to ensure a pool exists
    modifier graveExists(uint _gid) {
        require(_gid <= graveInfo.length - 1, 'Grave: Grave does not exist');
        _;
    }

    // Function to add a grave
    function addGrave(
        address _stakingToken,
        uint _depositType,
        address _deposit,
        address _rewardNft,
        uint256 _minimumStake,
        uint256 _mintingTime,
        uint256 _burnAmount,
        uint _burnHours,
        uint256 _maxBurn
    ) public onlyOwner() {
        graveInfo.push(GraveInfo({
            stakingToken: IBEP20(_stakingToken),
            depositType: DepositType(_depositType),
            deposit: _deposit,
            rewardNft: IRugZombieNft(_rewardNft),
            minimumStake: _minimumStake,
            mintingTime: _mintingTime,
            burnTokens: _burnAmount,
            burnHours: _burnHours,
            maxBurned: _maxBurn,
            isEnabled: false,
            totalStaked: 0,
            totalBurned: 0
        }));
    }

    // Function to set the amount of tokens to be burned when supply is high
    function setBurnedTokens(uint _gid, uint256 _amount) public onlyOwner() {
        graveInfo[_gid].burnTokens = _amount;
    }

    // Function to set the amount of hours reduced by burning
    function setBurnHours(uint _gid, uint _hours) public onlyOwner() {
        graveInfo[_gid].burnHours = _hours;
    }

    // Function to set the maximum burn allowed per minting cycle
    function setMaxBurned(uint _gid, uint256 _amount) public onlyOwner() {
        graveInfo[_gid].maxBurned = _amount;
    }

    // Function to set the enabled state of a grave
    function setIsEnabled(uint _gid, bool _enabled) public onlyOwner() {
        graveInfo[_gid].isEnabled = _enabled;
    }

    // Function to set the reward NFT for a grave
    function setRewardNft(uint _gid, address _nft) public onlyOwner() {
        graveInfo[_gid].rewardNft = IRugZombieNft(_nft);
    }

    // Function to set the minimum stake for a grave
    function setMinimumStake(uint _gid, uint256 _minimumStake) public onlyOwner() {
        graveInfo[_gid].minimumStake = _minimumStake;
    }

    // Function to set the minting time for a grave
    function setMintingTime(uint _gid, uint256 _mintingTime) public onlyOwner() {
        graveInfo[_gid].mintingTime = _mintingTime;
    }

    // Function to set the treasury address
    function setTreasury(address _treasury) public onlyOwner() {
        treasury = payable(_treasury);
    }

    // Function to get the number of graves
    function graveCount() public view returns(uint) {
        return graveInfo.length;
    }

    // Function to make the required deposit
    function deposit(uint _gid, uint256 _amount, uint _tokenId) public graveExists(_gid) {
        GraveInfo memory grave = graveInfo[_gid];
        require(grave.isEnabled, 'Grave: This grave is not enabled');
        require(grave.depositType != DepositType.NONE, 'Grave: No deposit is necessary for this grave');
        UserInfo storage user = userInfo[_gid][msg.sender];
        if (grave.depositType == DepositType.TOKEN) {
            _depositTokens(grave, user, _amount);
        } else {
            _depositNft(grave, user, _tokenId);
        }
    }

    // Function to enter staking in a grave
    function enterStaking(uint _gid, uint256 _amount) public isUnlocked(_gid) {
        GraveInfo storage grave = graveInfo[_gid];
        UserInfo storage user = userInfo[_gid][msg.sender];

        require(grave.isEnabled, 'Grave: This grave is not enabled');
        require(user.amount + _amount >= grave.minimumStake, 'Grave: Must stake at least the minimum amount');

        if (_amount > 0) {
            if (user.amount < grave.minimumStake) {
                user.nftMintDate = block.timestamp + grave.mintingTime;
                user.burnedAmount = 0;
            }
            require(grave.stakingToken.transferFrom(msg.sender, address(this), _amount));
            user.amount += _amount;
            grave.totalStaked += _amount;
        }

        emit Deposit(msg.sender, _gid, _amount);
    }

    // Function to burn zombie to reduce the minting timer
    function burnZombie(uint _gid, uint256 _amount) public isStaked(_gid) {
        GraveInfo storage grave = graveInfo[_gid];
        UserInfo storage user = userInfo[_gid][msg.sender];

        require(grave.isEnabled, 'Grave: This grave is not enabled');

        require(_amount >= grave.burnTokens, 'Grave: Insufficient tokens to burn');
        require(user.burnedAmount + _amount <= grave.maxBurned, 'Grave: You have already burned the maximum for this minting cycle');

        require(zombie.transferFrom(msg.sender, burnAddr, _amount));
        user.burnedAmount += _amount;
        grave.totalBurned += _amount;

        uint burnCycles = _amount / grave.burnTokens;
        user.nftMintDate -= ((grave.burnHours * 1 hours) * burnCycles);

        emit ZombieBurned(msg.sender, _gid, block.timestamp, _amount);
    }

    // Function to leave staking from a grave
    function leaveStaking(uint _gid, uint256 _amount) public {
        GraveInfo storage grave = graveInfo[_gid];
        UserInfo storage user = userInfo[_gid][msg.sender];

        require(user.amount >= _amount, 'Grave: Cannot unstake more than has been staked');
        uint256 endAmount = user.amount - _amount;
        require(grave.isEnabled || endAmount == 0, 'Grave: Must remove entire stake from inactive grave');
        require(endAmount >= grave.minimumStake || endAmount == 0, 'Grave: Can only unstake to minimum stake, or unstake entirely');

        if (user.amount >= grave.minimumStake && block.timestamp >= user.nftMintDate) {
            uint tokenId = grave.rewardNft.reviveRug(msg.sender);
            user.nftMintDate = block.timestamp + grave.mintingTime;
            user.burnedAmount = 0;
            emit MintNft(msg.sender, block.timestamp, address(grave.rewardNft), tokenId);
        }

        if (_amount > 0) {
            require(grave.stakingToken.transfer(msg.sender, _amount));
            user.amount -= _amount;
            grave.totalStaked -= _amount;
        }

        emit Withdraw(msg.sender, _gid, _amount);
    }

    // Function to deposit required tokens
    function _depositTokens(GraveInfo memory _grave, UserInfo storage _user, uint256 _amount) private {
        require(_amount >= 1, 'Grave: Must deposit at least one token');
        IBEP20 token = IBEP20(_grave.deposit);
        require(token.transferFrom(msg.sender, treasury, _amount));
        _user.deposited = true;
        _user.depositedAmount = _amount;
    }

    // Function to deposit required NFT
    function _depositNft(GraveInfo memory _grave, UserInfo storage _user, uint _tokenId) private {
        require(_tokenId > 0, 'Grave: Must provide the token ID');
        IRugZombieNft nft = IRugZombieNft(_grave.deposit);
        nft.transferFrom(msg.sender, treasury, _tokenId);
        require(nft.ownerOf(_tokenId) == treasury, 'Grave: NFT transfer failed');
        _user.deposited = true;
        _user.depositedId = _tokenId;
    }
}