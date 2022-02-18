pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./test/IMoonPad.sol";

contract MoonPadPreSale is Ownable {
    event MoonPadSold(uint256 moonPadAmount);
    event MoonPadClaimed(uint256 moonPadAmount);
    event SwapStagesSet();

    struct SwapStage {
        uint256 supply;
        uint256 rate;
    }

    IERC20 public pulseMoon;
    IMoonPad public moonPad;
    uint256 public maxSwapAmount;
    uint256 public minSwapAmount;
    uint256 public preSaleStart;
    uint256 public preSaleEnd;
    uint256 public tokensClaimTime;
    uint256 public totalSold;
    uint256 public totalSwapped;

    SwapStage[] public swapStages;

    mapping(address => uint256) public preBoughtTokens;

    /*
     * Params
     * IERC20 _pulseMoon - Address of Pulsemoon token
     * IMoonPad _moonPad - Address of MoonPad token
     * uint256 _maxMoonPadToBuy - Maximum amount of MoonPad a user is allowed to buy via swap
     * uint256 _maxSwapAmount - Maximum amount of Pulsemoon a user is allowed to swap
     * uint256 _minSwapAmount - Minimum amount of Pulsemoon a user is allowed to swap
     * uint256 _preSaleStart - PreSale start timestamp
     * uint256 _preSaleEnd - PreSale end timestamp
     * uint256 _tokensClaimTime - Timestamp of start of claiming tokens stage
     */
    constructor(
        IERC20 _pulseMoon,
        IMoonPad _moonPad,
        uint256 _maxSwapAmount,
        uint256 _minSwapAmount,
        uint256 _preSaleStart,
        uint256 _preSaleEnd,
        uint256 _tokensClaimTime
    ) {
        pulseMoon = _pulseMoon;
        moonPad = _moonPad;
        maxSwapAmount = _maxSwapAmount;
        minSwapAmount = _minSwapAmount;

        preSaleStart = _preSaleStart;
        preSaleEnd = _preSaleEnd;
        tokensClaimTime = _tokensClaimTime;
    }

    /*
     * Params
     * uint256 amountToSwap - Amount of Pulsemoon tokens to swap
     *
     * Function swaps Pulsemoon tokens to MoonPad tokens according to pre sale stages
     * Requires to pre sale start and not end yet.
     * Requires user to approve transferFrom and have corresponding token balance.
     */
    function swapPulsemoonToMoonPad(uint256 amountToSwap) external {
        require(block.timestamp >= preSaleStart, "Pre sale has not started");
        require(block.timestamp <= preSaleEnd, "Pre sale has ended");
        require(
            amountToSwap <= pulseMoon.balanceOf(msg.sender),
            "Not enough balance"
        );
        require(
            amountToSwap <= pulseMoon.allowance(msg.sender, address(this)),
            "Not enough allowance"
        );
        require(
            amountToSwap >= minSwapAmount && amountToSwap <= maxSwapAmount,
            "Amount of pulsemoon being swapped outside range"
        );

        pulseMoon.transferFrom(msg.sender, address(this), amountToSwap);
        uint256 moonPadAmount = calculateMoonPadAmount(amountToSwap);

        preBoughtTokens[msg.sender] += moonPadAmount;
        totalSwapped += moonPadAmount;

        emit MoonPadSold(moonPadAmount);
    }

    /*
     * Function mints MoonPad tokens that were bought during Pre Sale
     */
    function claimMoonPad() external returns (uint256 moonPadAmount) {
        require(block.timestamp >= tokensClaimTime, "Can't claim yet");
        require(preBoughtTokens[msg.sender] > 0, "Nothing to claim");

        moonPadAmount = preBoughtTokens[msg.sender];
        preBoughtTokens[msg.sender] = 0;
        moonPad.mint(msg.sender, moonPadAmount);

        emit MoonPadClaimed(moonPadAmount);
        return moonPadAmount;
    }

    /*
     * Params
     * uint256 _supply - Token supply for the stage. How many tokens can be provided for this stage?
     * uint256 _rate - Token rate for this stage.
     *** How many MoonPad token will user receive in exchange for 1 Pulsemoon token?
     *
     * Function overwrites existing swap stages with an array
     */
    function setSwapStages(SwapStage[] calldata _swapStages)
        external
        onlyOwner
    {
        //require(block.timestamp <= preSaleStart, "Pre sale has started");
        delete swapStages;
        for (uint256 i = 0; i < _swapStages.length; i++) {
            SwapStage memory stage = SwapStage(
                _swapStages[i].supply,
                _swapStages[i].rate
            );

            swapStages.push(stage);
        }

        emit SwapStagesSet();
    }

    /*
     * Params
     * uint256 stageId - ID index of the stage you want te edit
     * uint256 _supply - Token supply for the stage. How many tokens can be provided for this stage?
     * uint256 _rate - Token rate for this stage.
     *** How many MoonPad token will user receive in exchange for 1 Pulsemoon token?
     *
     * Function edits stage for pre sale
     */
    function editSwapStage(
        uint256 stageId,
        uint256 _supply,
        uint256 _rate
    ) external onlyOwner {
        //require(block.timestamp <= preSaleStart, "Pre sale has started");
        require(stageId < swapStages.length, "Invalid ID");
        swapStages[stageId].supply = _supply;
        swapStages[stageId].rate = _rate;
    }

    /*
     * Params
     * uint256 _preSaleStart - Start timestamp
     * uint256 _preSaleEnd - End timestamp
     * uint256 _tokensClaimTime - Timestamp of start of claiming tokens stage
     *
     * Function edits stage for presale
     */
    function setPreSaleTime(
        uint256 _preSaleStart,
        uint256 _preSaleEnd,
        uint256 _tokensClaimTime
    ) external onlyOwner {
        require(_preSaleStart < _preSaleEnd, "Wrong timeline");
        require(_preSaleEnd <= _tokensClaimTime, "Can't claim before the end");
        //require(block.timestamp <= preSaleStart, "Pre sale has started");

        preSaleStart = _preSaleStart;
        preSaleEnd = _preSaleEnd;
        tokensClaimTime = _tokensClaimTime;
    }

    /*
     * Params
     * uint256 _maxSwapAmount - Maximum amount of Pulsemoon a user is allowed to swap
     * uint256 _minSwapAmount - Minimum amount of Pulsemoon a user is allowed to swap
     *
     * Function sets Maximum amount of MoonPad a user is allowed to buy via swap
     */
    function setAllowedSwapAmount(
        uint256 _maxSwapAmount,
        uint256 _minSwapAmount
    ) external onlyOwner {
        maxSwapAmount = _maxSwapAmount;
        minSwapAmount = _minSwapAmount;
    }

    /*
     * Params
     * uint256 amountToSwap - Amount of tokens to swap
     *
     * Function returns amount of MoonPad tokens to swap
     * for requested amount of Pulsemoon tokens according to pre sale stages
     */
    function calculateMoonPadAmount(uint256 amountToSwap)
        public
        view
        returns (uint256 moonPadAmount)
    {
        uint256 sold = totalSwapped;
        moonPadAmount = 0;
        uint256 leftToSwap = amountToSwap;

        for (uint256 i = 0; i < swapStages.length; i++) {
            if (sold < swapStages[i].supply) {
                uint256 leftToSell = swapStages[i].supply - sold;
                uint256 needToTransfer = (leftToSwap * swapStages[i].rate) /
                    10**9;

                if (needToTransfer < leftToSell) {
                    moonPadAmount += needToTransfer;
                    break;
                } else {
                    if (i == swapStages.length - 1) {
                        revert("Not enough supply");
                    }
                    moonPadAmount += leftToSell;
                    sold = 0;
                    leftToSwap -= (leftToSell * 10**18) / swapStages[i].rate;
                }
            } else {
                sold -= swapStages[i].supply;
            }
        }

        return moonPadAmount;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMoonPad is IERC20{
    function mint(address account, uint256 amount) external;
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