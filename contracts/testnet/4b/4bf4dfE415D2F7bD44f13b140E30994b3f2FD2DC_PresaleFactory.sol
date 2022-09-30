/**
 *Submitted for verification at BscScan.com on 2022-09-29
*/

// SPDX-License-Identifier: MIT
// File: ETR/interface/IDEXRouter01.sol


pragma solidity >=0.4.22 <0.9.0;

interface IDEXRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}
// File: ETR/interface/IpETRToken.sol


pragma solidity ^ 0.8.7;

interface IpETRToken {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function getOwner() external view returns (address);
    function getCirculatingSupply() external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function setOwner(address owner) external;
    function setInitialDistributionFinished(bool value) external;
    function clearStuckBalance(address receiver) external;
    function rescueToken(address tokenAddress, uint256 tokens) external returns (bool success);
    function setPresaleFactory(address presaleFactory) external;
    function setAutoRebase(bool autoRebase) external;
    function setRebaseFrequency(uint256 rebaseFrequency) external;
    function setRewardYield(uint256 rewardYield, uint256 rewardYieldDenominator) external;
    function setNextRebase(uint256 nextRebase) external;
    function manualRebase() external;
}
// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: ETR/PresaleFactory.sol


pragma solidity ^ 0.8.7;





contract PresaleFactory is Ownable {
    IpETRToken _pETRAddress;
    IERC20 _busdAddress;
    IDEXRouter01 public _bsc01Router;

    // min/max cap
    uint256 public minCapBUSD                                       = 500 * 10 ** 18;
    uint256 public maxCapBUSD                                       = 5000 * 10 ** 18;
    uint256 public pTokenPrice_BUSD                                 = 7 * 10 ** 16;
    
    // presale period
    uint256 public start_time;
    uint256 public end_time;

    // owner address token receive
    address payable presaleOwnerAddress                             = payable(0x71981e8f2E7b609F1c2F448AcE44012C11905465);

    mapping (address => uint256) private _userPaidBUSD;

    constructor(address _router, address _pETR, address _busd) {
        _bsc01Router = IDEXRouter01(_router);
        _pETRAddress = IpETRToken(_pETR);
        _busdAddress = IERC20(_busd);
    }

    function buyTokensByBUSD(uint256 _amountPrice) external {
        require(block.timestamp >= start_time && block.timestamp <= end_time, "PresaleFactory: Not presale period");

        // token amount user want to buy
        uint256 tokenAmount = _amountPrice / pTokenPrice_BUSD * 10 ** 18;

        uint256 currentPaid = _userPaidBUSD[msg.sender];
        require(currentPaid + _amountPrice >= minCapBUSD && currentPaid + _amountPrice <= maxCapBUSD, "PresaleFactory: The price is not allowed for presale.");
        
        // transfer BUSD to owners
        _busdAddress.transferFrom(msg.sender, presaleOwnerAddress, _amountPrice);

        // transfer pETR token to user
        _pETRAddress.transfer(msg.sender, tokenAmount);

        // add BUSD user bought
        _userPaidBUSD[msg.sender] += _amountPrice;

        emit Presale(address(this), msg.sender, tokenAmount);
    }

    function buyTokensByBNB() external payable {
        require(block.timestamp >= start_time && block.timestamp <= end_time, "PresaleFactory: Not presale period");
        
        require(msg.value > 0, "Insufficient BNB amount");
        uint256 amountPrice = getLatestBNBPrice (msg.value);
 
        // token amount user want to buy
        uint256 tokenAmount = amountPrice / pTokenPrice_BUSD * 10 ** 18;

        uint256 currentPaid = _userPaidBUSD[msg.sender];
        require(currentPaid + amountPrice >= minCapBUSD && currentPaid + amountPrice <= maxCapBUSD, "PresaleFactory: The price is not allowed for presale.");
        
        // transfer BNB to owner
        presaleOwnerAddress.transfer(msg.value);

        // transfer pETR token to user
        _pETRAddress.transfer(msg.sender, tokenAmount);

        // add BUSD user bought
        _userPaidBUSD[msg.sender] += amountPrice;

        emit Presale(address(this), msg.sender, tokenAmount);
    }

    function getLatestBNBPrice(uint256 _amount) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = _bsc01Router.WETH();
        path[1] = address(_busdAddress);

        uint256[] memory price_out = _bsc01Router.getAmountsOut(_amount, path);
        return price_out[1];
    }

    function withdrawAll() external onlyOwner{
        uint256 balance = _pETRAddress.balanceOf(address(this));
        if(balance > 0) {
            _pETRAddress.transfer(msg.sender, balance);
        }

        emit WithdrawAll (msg.sender, balance);
    }

    function getUserPaidBUSD () public view returns (uint256) {
        return _userPaidBUSD[msg.sender];
    }

    function setMinCapBUSD(uint256 _minCap) external onlyOwner {
        minCapBUSD = _minCap;

        emit SetMinCap(_minCap);
    }

    function setMaxCapBUSD(uint256 _maxCap) external onlyOwner {
        maxCapBUSD = _maxCap;

        emit SetMaxCap(_maxCap);
    }

    function setStartTime(uint256 _time) external onlyOwner {
        start_time = _time;

        emit SetStartTime(_time);
    }

    function setEndTime(uint256 _time) external onlyOwner {
        end_time = _time;

        emit SetEndTime(_time);
    }

    function setpTokenPriceBUSD(uint256 _pTokenPrice) external onlyOwner {
        pTokenPrice_BUSD = _pTokenPrice;

        emit SetpTokenPrice(_pTokenPrice, 1);
    }

    function setPresaleOwnerAddress(address _add) external onlyOwner {
        presaleOwnerAddress = payable(_add);

        emit SetPresaleOwnerAddress (_add);
    }

    event Presale(address _from, address _to, uint256 _amount);
    event SetMinCap(uint256 _amount);
    event SetMaxCap(uint256 _amount);
    event SetpTokenPrice(uint256 _price, uint _type);
    event SetPresaleOwnerAddress(address _add);
    event SetStartTime(uint256 _time);
    event SetEndTime(uint256 _time);
    event WithdrawAll(address addr, uint256 astro);

    receive() payable external {}

    fallback() payable external {}
}