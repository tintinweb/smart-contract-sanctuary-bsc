// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interface/IUniswapV2Factory.sol";
import "./interface/IPancakeRouter02.sol";

contract SBB is IERC20, IERC20Metadata, Ownable {
    address private constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private constant USDT_ADDRESS = 0x55d398326f99059fF775485246999027B3197955;
    uint256 private constant USDT_DECIMALS = 18;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name = "SBB Token";
    string private _symbol = "SBB";

    address private _reserveAddress;
    address private _marketAddress;
    uint256 private _reserveFee = 20;
    uint256 private _marketFee = 18;
    mapping(address => bool) public isExcludedFromFee;

    uint256[2] private _buyAmounts = [20 * 10**USDT_DECIMALS, 500 * 10**USDT_DECIMALS];

    uint256 public _startTime;

    IPancakeRouter02 public  uniswapV2Router;
    address public uniswapV2Pair;
    mapping(address => uint256) public buyUsdtBalance;


    constructor(address reserveAddress_, address marketAddress_) {
        _mint(msg.sender, 100000000 * 10**18);

        _reserveAddress = reserveAddress_;
        _marketAddress = marketAddress_;
        isExcludedFromFee[msg.sender] = true;

        uniswapV2Router = IPancakeRouter02(ROUTER_ADDRESS);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), USDT_ADDRESS);

        _startTime = block.timestamp;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function setExcludedFromFee(address account, bool state) external onlyOwner {
        isExcludedFromFee[account] = state;
    }

    function setStartTime(uint256 time) external onlyOwner {
        _startTime = time;
    }

    function setReserveAddress(address account) external onlyOwner {
        _reserveAddress = account;
    }

    function setMarketAddress(address account) external onlyOwner {
        _marketAddress = account;
    }

    function setReserveFee(uint256 fee) external onlyOwner {
        _reserveFee = fee;
    }

    function setMarketFee(uint256 fee) external onlyOwner {
        _marketFee = fee;
    }

    function setBuyAmounts(uint256[2] calldata amounts) external onlyOwner {
        _buyAmounts = amounts;
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        if(isExcludedFromFee[from] || isExcludedFromFee[to]) {
            _tokenTransfer(from, to, amount);
        } else {
            if(from == uniswapV2Pair){
                _tokenTransferBuy(from, to, amount);
            } else if (to == uniswapV2Pair) {
                _tokenTransferWithFees(from, to, amount);
            } else {
                _tokenTransfer(from, to, amount);
            }
        }

        _afterTokenTransfer(from, to, amount);
    }

    function _tokenTransferBuy(
        address from,
        address to,
        uint256 amount
    ) private {
        if (block.timestamp - _startTime > 6 days) {
            _tokenTransferWithFees(from, to, amount);
            return;
        }

        uint256 usdtBalance = getBuyUsdtBalance(amount);
        buyUsdtBalance[to] = buyUsdtBalance[to] + usdtBalance;

        if (block.timestamp - _startTime <= 3 days) {
            require(buyUsdtBalance[to] <= _buyAmounts[0], "exceed the limit of buying token");
        } else if (block.timestamp - _startTime <= 6 days) {
            require(buyUsdtBalance[to] <= _buyAmounts[0] + _buyAmounts[1], "exceed the limit of buying token");
        }

        _tokenTransferWithFees(from, to, amount);
    }

    function _tokenTransferWithFees(
        address from,
        address to,
        uint256 amount
    ) private {
        _tokenTransfer(from, _reserveAddress, amount * _reserveFee / 1000);
        _tokenTransfer(from, _marketAddress, amount * _marketFee / 1000);
        _tokenTransfer(from, to, amount * (1000 - _marketFee - _reserveFee) / 1000);
    }

    function _tokenTransfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        require(_balances[from] > 0, "not zero balance");
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function getBuyUsdtBalance(uint256 balance) public view returns(uint256){
        address[] memory routerAddress = new address[](2);
        routerAddress[0] = USDT_ADDRESS;
        routerAddress[1] = address(this);
        uint[] memory amounts = uniswapV2Router.getAmountsIn(balance, routerAddress);
        return amounts[0];
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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

pragma solidity ^0.8.6;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
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

pragma solidity ^0.8.6;

interface IPancakeRouter01 {
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

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interface/IUniswapV2Pair.sol";
import "./interface/IPancakeRouter02.sol";

import "./UserRegistry.sol";

contract RewardPool is Ownable, UserRegistry {
    struct User {
        uint256 amount;
        uint256 rewardMax;
        uint256 rewardFree;
        uint256 rewardBalance;
        uint256 rewardPerBlock;
        uint256 rewardLastBlock;
        uint256 inviteValid;
        uint256 inviteFree;
        uint256 inviteBalance;
        bool isValid;
        bool isExist;
    }

    struct Pool {
        address owner;
        uint256 fee;
        uint256 amount;
    }

    // bsc-mainnet
    address private constant ROUTER_ADDRESS = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address private constant USDT_ADDRESS = address(0x55d398326f99059fF775485246999027B3197955);
    address private constant SBB_ADDRESS = address(0x29C10E2d41e9D868840AAb5C1A4a4653087A853b);
    address private constant PAIR_ADDRESS = address(0xeB8c9CC84B09a7aB2311EAa7fb1b15EE09770d5b);
    address private constant BURN_ADDRESS = address(0x000000000000000000000000000000000000dEaD);
    address private constant RECEIVE_ADDRESS = address(0x76e207cB77874Cc01E9b86e97e135C0079E7E833);
    // bsc-testnet
    // address private constant ROUTER_ADDRESS = address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    // address private constant USDT_ADDRESS = address(0xd2Cc0A0d84cE778c4907044f73604f36a45aA389);
    // address private constant SBB_ADDRESS = address(0xAb1E81126060e08AB6805ae89812F01e2117F481);
    // address private constant PAIR_ADDRESS = address(0x350f16cA837B94BB4fE045Ac75174cb83051acf1);
    // address private constant BURN_ADDRESS = address(0x000000000000000000000000000000000000dEaD);
    // address private constant RECEIVE_ADDRESS = address(0xfa62C8bcA1495246584eCF5adF33B162656c573f);

    uint256 private constant VALID_AMOUNT = 300 * 10**18;

    mapping(address => User) public users;
    uint256 public userCount;

    Pool[] public pools;

    uint256 public stakedTotal;

    mapping(uint256 => uint256) public balanceDay;

    function getPrice(address token1, address token2, uint256 amount) public view returns(uint256) {
        address[] memory path = new address[](2);
        path[0] = address(token1);
        path[1] = address(token2);
        (uint256 amount0, uint256 amount1, ) = IUniswapV2Pair(PAIR_ADDRESS)
            .getReserves();
        if (amount0 == 0 || amount1 == 0) {
            return 0;
        }
        return IPancakeRouter02(ROUTER_ADDRESS).getAmountsOut(amount, path)[1];
    }

    function getPriceSBB(uint256 amount) public view returns(uint256) {
        return getPrice(SBB_ADDRESS, USDT_ADDRESS, amount);
    }

    function getPriceUSDT(uint256 amount) public view returns(uint256) {
        return getPrice(USDT_ADDRESS, SBB_ADDRESS, amount);
    }

    function pendingReward(address account) external view returns(uint256) {
        return users[account].rewardBalance + users[account].rewardPerBlock * (block.number - users[account].rewardLastBlock);
    }

    function depositSBB(uint256 amount, address recommender) external {
        uint256 usdtAmount = getPriceSBB(amount) * 5;
        IERC20(SBB_ADDRESS).transferFrom(msg.sender, BURN_ADDRESS, amount);
        IERC20(USDT_ADDRESS).transferFrom(msg.sender, address(this), usdtAmount);
        _deposit(usdtAmount, recommender);
    }

    function depositUSDT(uint256 amount, address recommender) external {
        uint256 sbbAmount = getPriceUSDT(amount) / 5;
        IERC20(USDT_ADDRESS).transferFrom(msg.sender, address(this), amount);
        IERC20(SBB_ADDRESS).transferFrom(msg.sender, BURN_ADDRESS, sbbAmount);
        _deposit(amount, recommender);
    }

    function redeposit() external {
        _checkIsOut(msg.sender);

        _updateUser(msg.sender, 0);

        User storage user = users[msg.sender];

        uint256 amount = user.rewardBalance + user.inviteBalance;
        if (amount + user.rewardFree + user.inviteFree > user.rewardMax) {
            amount = user.rewardMax - user.rewardFree - user.inviteFree;
        }

        user.inviteBalance = 0;
        user.rewardBalance = 0;

        _updateUser(msg.sender, amount);
    }

    function withdraw() public {
        _updateUser(msg.sender, 0);

        User storage user = users[msg.sender];

        uint256 amount = user.rewardBalance + user.inviteBalance;

        if (amount + user.rewardFree + user.inviteFree > user.rewardMax) {
            amount = user.rewardMax - user.rewardFree - user.inviteFree;
        }

        uint256 day = block.timestamp / 1 days;
        if (balanceDay[day] >= IERC20(USDT_ADDRESS).balanceOf(address(this)) * 30 / 100) {
            amount = amount * 50 / 100;
        } else if (balanceDay[day] >= IERC20(USDT_ADDRESS).balanceOf(address(this)) / 5) {
            amount = amount * 70 / 100;
        }

        user.rewardFree += user.rewardBalance;
        user.inviteFree += user.inviteBalance;
        user.inviteBalance = 0;
        user.rewardBalance = 0;

        IERC20(USDT_ADDRESS).transfer(msg.sender, amount * 95 / 100);

        _checkIsOut(msg.sender);

        address _recommender = recommender(msg.sender);
        if (_recommender == address(0)) return;
        User storage recommenderUser = users[_recommender];
        if (recommenderUser.amount > 0) recommenderUser.inviteBalance += amount * 2 / 100;
        _updateGroup(recommender(_recommender), amount * 5 / 1000, 6);
        balanceDay[day] += amount;
    }

    function exit() external {
        withdraw();

        User storage user = users[msg.sender];

        address _recommender = recommender(msg.sender);
        if (_recommender == address(0)) return;
        User storage recommenderUser = users[_recommender];
        if (recommenderUser.amount > 0) recommenderUser.inviteBalance += user.amount * 5 / 100;
        _updateGroup(recommender(_recommender), user.amount * 5 / 1000, 6);

        if (user.amount > 0) {
            IERC20(USDT_ADDRESS).transfer(msg.sender, user.amount * 92 / 100);
            user.amount = 0;
            user.rewardMax = 0;
            user.rewardFree = 0;
            user.rewardBalance = 0;
            user.rewardPerBlock = 0;
            user.inviteFree = 0;
            user.inviteBalance = 0;
        }
    }

    function addPool(uint256 fee, address owner) external onlyOwner {
        pools.push(Pool({
            owner: owner,
            fee: fee,
            amount: 0
        }));
    }

    function setPool(uint256 pid, uint256 fee, address owner) external onlyOwner {
        pools[pid] = Pool({
            owner: owner,
            fee: fee,
            amount: pools[pid].amount
        });
    }

    function withdrawPool(uint256 pid, uint256 amount) external {
        require(pools[pid].owner == msg.sender, "Only pool owner call");
        pools[pid].amount -= amount;
        IERC20(USDT_ADDRESS).transfer(msg.sender, amount);
    }

    function _deposit(uint256 amount, address _recommender) private {
        _checkIsOut(msg.sender);

        stakedTotal += amount;

        User storage user = users[msg.sender];

        if (!user.isExist) {
            _recommender = join(msg.sender, _recommender);
            user.isExist = true;
            userCount++;
        }

        _updateUser(msg.sender, amount);

        IERC20(USDT_ADDRESS).transfer(RECEIVE_ADDRESS, amount * 68 / 1000);

        for (uint256 i = 0; i < pools.length; i++) {
            pools[i].amount += amount * pools[i].fee / 1000;
        }

        if (_recommender == address(0)) return;

        User storage recommenderUser = users[_recommender];
        if (recommenderUser.amount > 0) recommenderUser.inviteBalance += amount * 5 / 100;
        if (!user.isValid && user.amount >= VALID_AMOUNT) {
            user.isValid = true;

            recommenderUser.inviteValid++;
        }
        _updateUser(_recommender, 0);
        _updateGroup(recommender(_recommender), amount * 5 / 1000, 6);
    }

    function _updateUser(address account, uint256 amount) private {
        User storage user = users[account];

        if (user.amount > 0) {
            user.rewardBalance += user.rewardPerBlock * (block.number - user.rewardLastBlock);
        }

        user.rewardLastBlock = block.number;

        user.amount += amount;

        if (user.inviteValid < 10) {
            user.rewardMax = user.amount * 2;
            user.rewardPerBlock = user.amount * 2 / 100 / 28800;
        } else if (user.inviteValid < 20) {
            user.rewardMax = user.amount * 3;
            user.rewardPerBlock = user.amount * 25 / 1000 / 28800;
        } else {
            user.rewardMax = user.amount * 4;
            user.rewardPerBlock = user.amount * 3 / 100 / 28800;
        }

        if (user.rewardFree + user.inviteFree + user.rewardBalance + user.inviteBalance >= user.rewardMax) {
            user.rewardPerBlock = 0;
        }
    }

    function _updateGroup(address account, uint256 amount, uint8 step) private {
        if (account == address(0)) return;
        if (step == 0) return;

        if (users[account].amount > 0) users[account].inviteBalance += amount;
        _updateUser(account, 0);

        _updateGroup(recommender(account), amount, step - 1);
    }

    function _checkIsOut(address account) private {
        User storage user = users[account];

        if (user.rewardFree + user.inviteFree >= user.rewardMax) {
            IERC20(USDT_ADDRESS).transfer(account, user.amount);
            user.amount = 0;
            user.rewardMax = 0;
            user.rewardFree = 0;
            user.rewardBalance = 0;
            user.rewardPerBlock = 0;
            user.inviteFree = 0;
            user.inviteBalance = 0;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./interface/IUserRegistry.sol";

contract UserRegistry is IUserRegistry {
    mapping(address => address) private _recommender;
    mapping(address => address[]) private _children;
    mapping(address => uint256) private _groupCount;

    function recommender(address account) public override view returns (address) {
        return _recommender[account];
    }

    function childrenLength(address account) public override view returns (uint256) {
        return _children[account].length;
    }

    function children(address account) public override view returns (address[] memory) {
        return _children[account];
    }

    function childrenPaged(address account, uint256 from, uint256 length) public override view returns (address[] memory childrens) {
        childrens = new address[](length);
        uint256 j;
        for (uint256 i = from; i < from + length; i++) {
            childrens[j++] = _children[account][i];
        }
    }

    function groupCount(address account) public override view returns(uint256) {
        return _groupCount[account];
    }

    function join(address account, address recommender_) internal returns (address) {
        require(recommender_ != account, "recommender can not be your self");

        if (_recommender[account] == address(0) && _children[account].length == 0) {
            _recommender[account] = recommender_;
            _children[recommender_].push(account);
            _updateGroupCount(recommender_, 6);
        }

        return _recommender[account];
    }

    function _updateGroupCount(address account, uint8 step) internal {
        if (account == address(0)) return;
        if (step == 0) return;

        _groupCount[account] += 1;

        _updateGroupCount(recommender(account), step - 1);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IUserRegistry {
    function recommender(address account) external view returns (address);

    function childrenLength(address account) external view returns (uint256);

    function children(address account) external view returns (address[] calldata);

    function childrenPaged(address account, uint256 from, uint256 length) external view returns (address[] calldata);

    function groupCount(address account) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SBBMiner is Ownable {
    using SafeMath for uint256;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }
    struct PoolInfo {
        IERC20 lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accTokenPerShare;
        uint256 lpBalance;
    }

    IERC20 public token;
    IERC20 public lptoken;
    uint256 public tokenPerBlock = 0;
    PoolInfo[] poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    constructor(IERC20 _token, IERC20 _lptoken, uint256 _startBlock) {
        token = _token;
        lptoken = _lptoken;
        startBlock = _startBlock;
    }

    function addThePool(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock =
            block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accTokenPerShare: 0,
                lpBalance: 0
            })
        );
    }

    function setThePool(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function pendingToken(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        if (user.amount == 0) {
            return 0;
        }

        uint256 accTokenPerShare = pool.accTokenPerShare;
        if (block.number > pool.lastRewardBlock && pool.lpBalance != 0) {
            uint256 multiplier = block.number.sub(pool.lastRewardBlock);
            uint256 tokenReward =
                multiplier.mul(tokenPerBlock).mul(pool.allocPoint).div(
                    totalAllocPoint
                );
            accTokenPerShare = accTokenPerShare.add(
                tokenReward.mul(1e12).div(pool.lpBalance)
            );
        }

        uint256 pending = user.amount.mul(accTokenPerShare).div(1e12).sub(user.rewardDebt);

        return pending;
    }

    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        if (pool.lpBalance == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = block.number.sub(pool.lastRewardBlock);
        uint256 tokenReward =
            multiplier.mul(tokenPerBlock).mul(pool.allocPoint).div(
                totalAllocPoint
            );
        pool.accTokenPerShare = pool.accTokenPerShare.add(
            tokenReward.mul(1e12).div(pool.lpBalance)
        );
        pool.lastRewardBlock = block.number;
    }

    function _claim(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(user.rewardDebt);
            safeTokenTransfer(
                msg.sender,
                pending
            );
        }
    }

    function claim(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        _claim(_pid);
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
    }

    function depositTheLp(uint256 _pid, uint256 _amount) public {
        _claim(_pid);
        depositLp(msg.sender, _amount, _pid);

        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdrawAndClaim(uint256 _pid, uint256 _amount) public {
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        _claim(_pid);
        withdrawLp(msg.sender, _amount, _pid);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public {
        UserInfo storage user = userInfo[_pid][msg.sender];
        withdrawLp(msg.sender, user.amount, _pid);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function emergencyWithdrawToken(uint256 _amount) public onlyOwner {
        token.transfer(msg.sender, _amount);
    }

    function safeTokenTransfer(address _to, uint256 _amount) internal {
        uint256 tokenBal = token.balanceOf(address(this));
        if (_amount > tokenBal) {
            token.transfer(_to, tokenBal.sub(100));
        } else {
            token.transfer(_to, _amount);
        }
    }

    function depositLp(address from, uint256 amount, uint256 pid) internal {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        pool.lpToken.transferFrom(
            from,
            address(this),
            amount
        );
        pool.lpBalance = pool.lpBalance.add(amount);
        user.amount = user.amount.add(amount);
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);

        tokenPerBlock = token.balanceOf(address(lptoken))
            .mul(lptoken.balanceOf(address(this)))
            .div(lptoken.totalSupply())
            .mul(3).div(100).div(28800)
            .mul(2);
    }

    function withdrawLp(address to, uint256 amount, uint256 pid) internal {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        pool.lpToken.transfer(to, amount);
        pool.lpBalance = pool.lpBalance.sub(amount);
        user.amount = user.amount.sub(amount);
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);

        tokenPerBlock = token.balanceOf(address(lptoken))
            .mul(lptoken.balanceOf(address(this)))
            .div(lptoken.totalSupply())
            .mul(3).div(100).div(28800)
            .mul(2);
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

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
  constructor() ERC20("Mock ERC20", "mockERC20") {
    _mint(msg.sender, 10000000000000000000000000000);
  }
}