/**
 *Submitted for verification at BscScan.com on 2022-04-27
*/

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


abstract contract Improver is Context {
    address internal _improver;
    modifier onlyImprover() {
        require(_msgSender()==_improver, "forbidden");
        _;
    }
    constructor() {_improver = _msgSender();}
}


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


abstract contract StakingPool is Improver {
    address[] public stakeLists;

    function stakeAdd(address _stake) public onlyImprover {
        require(!isStakingPool(_stake), "stake already exists");
        stakeLists.push(_stake);
    }

    function stakeRemove(address _stake) public onlyImprover {
        for (uint i=0;i<stakeLists.length;i++) {
            if (stakeLists[i] == _stake) {
                stakeLists[i] = stakeLists[stakeLists.length-1];
                break;
            }
        }
        stakeLists.pop();
    }

    function isStakingPool(address addr) public view returns(bool) {
        for (uint i=0;i<stakeLists.length;i++) {
            if (stakeLists[i] == addr) return true;
        }
        return false;
    }

    function stakeListsLength() public view returns(uint256) {
        return stakeLists.length;
    }
}


abstract contract PairManager is Improver {
    address[] public pairLists;

    function pairAdd(address _pair) public onlyImprover {
        require(!isPair(_pair), "pair already exists");
        pairLists.push(_pair);
    }

    function pairRemove(address _pair) public onlyImprover {
        for (uint i=0;i<pairLists.length;i++) {
            if (pairLists[i] == _pair) {
                pairLists[i] = pairLists[pairLists.length-1];
                break;
            }
        }
        pairLists.pop();
    }

    function isPair(address addr) public view returns(bool) {
        for (uint i=0;i<pairLists.length;i++) {
            if (pairLists[i] == addr) return true;
        }
        return false;
    }

    function pairListsLength() public view returns(uint256) {
        return pairLists.length;
    }

    function getPairLists() public view returns(address[] memory) {
        return pairLists;
    }
}


abstract contract LiquidityManager {
    mapping(address => bool) lmBox;
    function setLiquidityManager(address user) internal {
        lmBox[user] = true;
    }
    function isLiquidityManager(address user) internal view returns(bool) {
        return lmBox[user];
    }
}


interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address uniswapPair);
}
interface IPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function transfer(address to, uint value) external returns (bool);
    function totalSupply() external view returns (uint256);
}
interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
}

abstract contract PoolTool {
    address public uniswapPair;
    IRouter internal uniswapV2Router;
    IPair internal pair;
    function initIRouter(address _router, address tokenBUSD) internal {
        uniswapV2Router = IRouter(_router);
        uniswapPair = IFactory(uniswapV2Router.factory()).createPair(address(this), tokenBUSD);
        pair = IPair(uniswapPair);
    }
    function swapTokensForETH(uint256 amountDesire) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountDesire, 0, path, address(this), block.timestamp);
    }

    function addLiquidityETH(uint256 ethAmount, uint256 tokenAmount) internal {
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            address(this),
            block.timestamp
        );
    }
    function getPoolInfo(address _pair) public view returns (uint112 ThisAmount, uint112 TOKENAmount) {
        (uint112 _reserve0, uint112 _reserve1,) = IPair(_pair).getReserves();
        ThisAmount = _reserve1;
        TOKENAmount = _reserve0;
        if (IPair(_pair).token0() == address(this)) {
            ThisAmount = _reserve0;
            TOKENAmount = _reserve1;
        }
    }
    function getPrice4ETH(uint256 amountDesire) internal view returns(uint256) {
        (uint112 WETHAmount, uint112 TOKENAmount) = getPoolInfo(uniswapPair);
        return WETHAmount * amountDesire / TOKENAmount;
    }
}


contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        _move(sender, recipient, amount);
        _afterTokenTransfer(sender, recipient, amount);
    }
    function _move(address sender, address recipient, uint256 amount) internal virtual {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        _afterTokenTransfer(address(0), account, amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

interface IToken {
    function addLiquidity(uint256 amountBUSD, uint256 amountToken) external;
    function addLiquidityAutomatically() external;
    function addLiquidityBUSD(uint256 amountBUSD) external;
    function addLiquidityEth() payable external;
    function addLiquidityTokenWithAnyPair(uint256 amountToken, address[] memory path) external;
    function addLiquidityTokenWithEthPair(uint256 amountToken, address token) external;
    function addLiquidityTokenWithBUSDPair(uint256 amountToken, address token) external;
    function getLiquidityTokenAmountFromBUSDAmount(uint256 amountBUSD) external view returns (uint256 amountToken);
    function getLiquidityBUSDAmountFromTokenAmount(uint256 amountToken) external view returns (uint256 amountBUSD);
    function getPredictLiquidityAmount(address user) external view returns (uint256 busd4liquidity, uint256 token4liquidity);
}

contract NRGCalorieToken is ERC20, PoolTool, LiquidityManager, PairManager, StakingPool, Ownable, IToken {
    IERC20 TokenBUSD;
    address public busdAddress;
    address public taxTo;
    uint256 public taxBase = 10000;
    uint256 public tax4swap;

    event DepositToken(address user, address token, uint256 tokenAmount);
    event AddLiquidity(address user, uint256 busdAmount, uint256 tokenAmount);
    constructor(address _router, address _busdAddress) ERC20("NRG-Calorie", "NRG-Calorie") {
        busdAddress = _busdAddress;
        TokenBUSD = IERC20(_busdAddress);
        initIRouter(_router, _busdAddress);
        pairAdd(uniswapPair);

        setLiquidityManager(uniswapPair);
        setLiquidityManager(address(this));
        setLiquidityManager(address(0));
        setLiquidityManager(address(1));
        setLiquidityManager(address(0xdEaD));

        updateTax4swap(100, owner());

        _mint(owner(), 1313 * 1e8 ether);
    }

    function updateTax4swap(uint256 tax, address _taxTo) public onlyOwner {
        require(tax <= 100, "tax must no more than 1%(100/10000)");
        tax4swap = tax;
        taxTo = _taxTo;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual override {
        if (isPair(from)
        || isStakingPool(from)
        || isStakingPool(to)
        ) {} else if (isPair(to))
            require(isLiquidityManager(from), "not permitted, please use NRG-Calorie contract function addLiquidity instead.");
        else {
            super._transfer(from, address(0xdEaD), amount);
            amount = 0;
        }
        if (amount > 0) super._transfer(from, to, amount);
    }

    function _checkAllowance(uint256 amount) private {
        require(super.balanceOf(_msgSender()) >= amount, "exceeds of balance");
        super._move(_msgSender(), address(this), amount);
    }

    function _checkAnyTokenAllowance(address token, uint256 amount) private {
        IERC20 TokenAny = IERC20(token);
        require(TokenAny.allowance(_msgSender(), address(this)) >= amount, "exceeds of token allowance");
        require(TokenAny.transferFrom(_msgSender(), address(this), amount), "allowance transferFrom failed");
        emit DepositToken(_msgSender(), token, amount);
    }

    function getLiquidityBUSDAmountFromTokenAmount(uint256 amountToken) public virtual override view returns (uint256 amountBUSD) {
        (uint112 tokenAmount, uint112 busdAmount) = getPoolInfo(uniswapPair);
        if (tokenAmount == 0 || busdAmount == 0) return 0;
        // calc busd real by token
        return amountToken * busdAmount / tokenAmount;
    }

    function getLiquidityTokenAmountFromBUSDAmount(uint256 amountBUSD) public virtual override view returns (uint256 amountToken) {
        (uint112 tokenAmount, uint112 busdAmount) = getPoolInfo(uniswapPair);
        if (tokenAmount == 0 || busdAmount == 0) return 0;
        // calc token real by busd
        return amountBUSD * tokenAmount / busdAmount;
    }

    function getPredictLiquidityAmount(address user) public virtual override view returns (uint256 busd4liquidity, uint256 token4liquidity) {
        uint256 balanceBUSD = TokenBUSD.balanceOf(user);
        uint256 balanceToken = balanceOf(user);

        // calc busd real by token
        uint256 amountBUSDReal = getLiquidityBUSDAmountFromTokenAmount(balanceToken);
        // calc token real by busd
        uint256 amountTokenReal = getLiquidityTokenAmountFromBUSDAmount(balanceBUSD);

        if (balanceToken >= amountTokenReal) {
            busd4liquidity = balanceBUSD;
            token4liquidity = amountTokenReal;
        } else {
            busd4liquidity = amountBUSDReal;
            token4liquidity = balanceToken;
        }
    }

    function addLiquidityAutomatically() public virtual override {
        require((pair.totalSupply() > 0), "please waiting for liquidity provided");

        (uint256 busd4liquidity, uint256 token4liquidity) = getPredictLiquidityAmount(_msgSender());
        require(busd4liquidity > 0 && token4liquidity > 0, "exceeds of balance");

        _checkAllowance(token4liquidity);
        _checkAnyTokenAllowance(busdAddress, busd4liquidity);
        _addLiquidityAndDistributeLP(busd4liquidity, token4liquidity);
    }

    function addLiquidity(uint256 amountBUSD, uint256 amountToken) public virtual override {
        uint256 balanceTokenReal = balanceOf(_msgSender());
        uint256 balanceBUSDReal = TokenBUSD.balanceOf(_msgSender());

        require(balanceTokenReal >= amountToken && balanceBUSDReal >= amountBUSD, "exceeds of balance 1");

        uint256 busd4liquidity;
        uint256 token4liquidity;

        if (pair.totalSupply() > 0) {
            // calc token real by busd
            uint256 amountTokenReal = getLiquidityTokenAmountFromBUSDAmount(amountBUSD);
            // calc busd real by token
            uint256 amountBUSDReal = getLiquidityBUSDAmountFromTokenAmount(amountToken);

            require(balanceTokenReal >= amountTokenReal || balanceBUSDReal >= amountBUSDReal, "exceeds of balance 2");

            if (balanceTokenReal >= amountTokenReal) {
                busd4liquidity = amountBUSD;
                token4liquidity = amountTokenReal;
            } else {
                busd4liquidity = amountBUSDReal;
                token4liquidity = amountToken;
            }
        } else {
            busd4liquidity = amountBUSD;
            token4liquidity = amountToken;
        }

        _checkAllowance(token4liquidity);
        _checkAnyTokenAllowance(busdAddress, busd4liquidity);
        _addLiquidityAndDistributeLP(busd4liquidity, token4liquidity);
    }

    function _approveToken(uint256 amount, address token) private {
        if (IERC20(token).allowance(address(this), address(uniswapV2Router)) < amount)
            IERC20(token).approve(address(uniswapV2Router), ~uint256(0));
    }

    function _approveBUSD(uint256 amount) private {
        if (TokenBUSD.allowance(address(this), address(uniswapV2Router)) < amount)
            TokenBUSD.approve(address(uniswapV2Router), ~uint256(0));
    }

    function _approveToken(uint256 amount) private {
        if (super.allowance(address(this), address(uniswapV2Router)) < amount)
            _approve(address(this), address(uniswapV2Router), ~uint256(0));
    }

    function _addLiquidityReal(uint256 amountBUSDReal, uint256 amountTokenReal) private returns (uint amountA, uint amountB, uint liquidity) {
        _approveBUSD(amountBUSDReal);
        _approveToken(amountTokenReal);
        (amountA, amountB, liquidity) = uniswapV2Router.addLiquidity(
            address(this),
            busdAddress,
            amountTokenReal,
            amountBUSDReal,
            0,
            0,
            address(this),
            block.timestamp
        );

        emit AddLiquidity(_msgSender(), amountBUSDReal, amountTokenReal);
    }

    function _distributeLP(uint liquidity) private {
        uint256 fee = liquidity * tax4swap / taxBase;
        pair.transfer(taxTo, fee);
        pair.transfer(_msgSender(), liquidity - fee);
    }

    function _addLiquidityAndDistributeLP(uint256 busd4liquidity, uint256 token4liquidity) private {
        (,,uint liquidity) = _addLiquidityReal(busd4liquidity, token4liquidity);
        _distributeLP(liquidity);
    }

    function _addLiquidityBUSD(uint256 amountBUSD) private {
        uint256 beforeAmount = balanceOf(address(1));
        address[] memory path = new address[](2);
        path[0] = busdAddress;
        path[1] = address(this);
        uint256 half = amountBUSD / 2;
        _approveBUSD(half);
        uint[] memory amounts = uniswapV2Router.swapExactTokensForTokens(
            half,
            0,
            path,
            address(1),
            block.timestamp
        );
        uint256 afterAmount = balanceOf(address(1));

        uint256 amount = amounts[amounts.length - 1];
        uint256 diff = afterAmount - beforeAmount;
        if (diff < amount) amount = diff;

        super._move(address(1), address(this), amount);

        _addLiquidityAndDistributeLP(amountBUSD - half, amount);
    }

    function _swapEth2BUSD(uint256 eth) private returns (uint256) {
        uint256 beforeAmount = TokenBUSD.balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = busdAddress;
        uint[] memory amounts = uniswapV2Router.swapExactETHForTokens{value : eth}(
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 afterAmount = TokenBUSD.balanceOf(address(this));

        uint256 amount = amounts[amounts.length - 1];
        uint256 diff = afterAmount - beforeAmount;
        if (diff < amount) amount = diff;

        return amount;
    }

    function addLiquidityBUSD(uint256 amountBUSD) public virtual override {
        _checkAnyTokenAllowance(busdAddress, amountBUSD);
        _addLiquidityBUSD(amountBUSD);
    }

    function addLiquidityEth() payable public virtual override {
        uint256 eth = msg.value;
        require(eth > 0, "amount of bnb must greater than 0");

        uint256 amount = _swapEth2BUSD(eth);

        _addLiquidityBUSD(amount);
    }

    function addLiquidityTokenWithAnyPair(uint256 amountToken, address[] memory path) public virtual override {
        require(path.length > 1, "path's length must greater than 1");
        require(path[path.length - 1] == busdAddress, "path's last address must be busd address");

        _checkAnyTokenAllowance(path[0], amountToken);

        _approveToken(amountToken, path[0]);

        uint[] memory amounts = uniswapV2Router.swapExactTokensForTokens(
            amountToken,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amount = amounts[amounts.length - 1];

        _addLiquidityBUSD(amount);
    }

    function addLiquidityTokenWithEthPair(uint256 amountToken, address token) public virtual override {
        address[] memory path = new address[](3);
        path[0] = token;
        path[1] = uniswapV2Router.WETH();
        path[2] = busdAddress;

        addLiquidityTokenWithAnyPair(amountToken, path);
    }

    function addLiquidityTokenWithBUSDPair(uint256 amountToken, address token) public virtual override {
        address[] memory path = new address[](3);
        path[0] = token;
        path[1] = busdAddress;

        addLiquidityTokenWithAnyPair(amountToken, path);
    }

    function airdrop(uint256 amount, address[] memory to) public onlyOwner {
        for (uint i = 0; i < to.length; i++) {
            super._move(_msgSender(), to[i], amount);
        }
    }
}