/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol


pragma solidity >=0.5.0;

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

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol


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

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol


pragma solidity >=0.6.2;


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

// File: contracts/MeToken111111.sol

pragma solidity ^0.8.15;
//SPDX-License-Identifier: UNLICENSED





interface IAlNft {
    function rewardBalance(address account) external view returns (uint256);
    function claimRewards(address account) external;
    function currentReward(address account) external view returns(uint256);
    function totalRewards() external view returns(uint256);
    function totalExcludedRewardAmount() external view returns(uint256);
}

contract AlToken is Ownable, IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 public _totalSupply;
    uint256 private _maxSupply;
    uint256 public rewardSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    IAlNft public alNft;
    IUniswapV2Router02 public router;
    address public pair;
    mapping (address => bool) public _isExcludedFromFee;
    mapping(address => bool) public blacklist;
    bool inSwap;
    // fees
    uint256 private _totalBuyFee;
    uint256 private _totalSellFee;
    uint256 private _feeRate;
    // fee distribution wallets
    address private _walletA;
    address private _walletB;
    address private _walletC;
    address private _burnWallet;
    // liquidity
    uint256 private numTokensToAddToLiquidity;
    uint256 public rewardDuration;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event AutoLP(bool flag);
    event Received(address, uint256);

    function init() private onlyOwner {
        uint256 oneMillion = (10**_decimals) * (10**7);
        _totalSupply = oneMillion; // 1 milion
        rewardSupply = oneMillion * 20; // 20 million
        _maxSupply = _totalSupply + rewardSupply; // 21 milion
        _balances[msg.sender] = _totalSupply;

        setupLP();
        _totalBuyFee = 600;     // buy fee  : 6%
        _totalSellFee = 1500;   // sell fee : 15%
        _feeRate = 10000;
        numTokensToAddToLiquidity = 1 ether;

        _walletA = 0x3244585147151AaAe3B05bc71D6217150F61f349;
        _walletB = 0x15C6A26A9A24d856DB42F7baDC2c4FD68096e61F;
        _walletC = 0xbEF53b386767DD99D785cb949709EA2c6C3e745b;
        _burnWallet = 0x000000000000000000000000000000000000dEaD;
        setRewardDuration(12*3600); // 12 hours
    }

    constructor (
        string memory n_,
        string memory s_,
        uint8 d_
    ) {
        _name = n_;
        _symbol = s_;
        _decimals = d_;
        init();
    }

    function setupLP() public onlyOwner {
        IUniswapV2Router02 _uniswapV2Router;
        if (block.chainid == 56) // bsc mainnet
            _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        else if (block.chainid == 97) // bsc testnet
            _uniswapV2Router = IUniswapV2Router02(0x1Ed675D5e63314B760162A3D1Cae1803DCFC87C7);
        // Create a uniswap pair for this new token
        pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());
        // set the rest of the contract variables
        router = _uniswapV2Router;
        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
    }

    function setRewardDuration(uint256 duration) public onlyOwner {
        rewardDuration = duration;
    }
    function setAutoLPThreshold(uint256 amount) public onlyOwner {
        numTokensToAddToLiquidity = amount;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        uint256 totalRewardFromNft = 0;
        if (address(alNft) != address(0)) {
            totalRewardFromNft = alNft.totalRewards();
        }
        return _totalSupply + totalRewardFromNft;
    }

    function maxSupply() public view returns(uint256) {
        return _maxSupply;
    }

    function setRewardSupply(uint256 _rewardSupply) public onlyOwner {
        rewardSupply = _rewardSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        uint256 balance = _balances[account];
        if (address(alNft) != address(0))
            balance += alNft.currentReward(account);
        return balance;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        if (address(alNft) == address(0))
            return;
        alNft.claimRewards(from);
        alNft.claimRewards(to);
    }

    function refreshTotalSupply() public returns (uint256) {
        if (address(alNft) == address(0))
            return 0;
        require(msg.sender == address(alNft), "[AlToken] This function can be called only from reward NFT!");
        _totalSupply += alNft.totalRewards();
        return _totalSupply;
    }

    function _basicTransfer(address from, address to, uint256 amount) internal returns (bool) {

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        _balances[from] = fromBalance - amount;
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _transferWithBuyFee(address from, address to, uint256 amount) internal returns(bool) {
        uint256 feeAmount = (amount * _totalBuyFee) / _feeRate;
        uint256 tAmount = amount - feeAmount;
        uint256 amountLP = (feeAmount * 200) / 600;
        uint256 amountA = (feeAmount * 200) / 600;
        uint256 amountB = (feeAmount * 200) / 600;

        _basicTransfer(from, address(this), amountLP);
        _basicTransfer(from, _walletA, amountA);
        _basicTransfer(from, _walletB, amountB);
        _basicTransfer(from, to, tAmount);
    }

    function _transferWithSellFee(address from, address to, uint256 amount) internal returns(bool) {
        uint256 feeAmount = (amount * _totalSellFee) / _feeRate;
        uint256 tAmount = amount - feeAmount;
        uint256 amountLP = (feeAmount * 300) / 1500;
        uint256 amountA = (feeAmount * 400) / 1500;
        uint256 amountB = (feeAmount * 400) / 1500;
        uint256 amountC = (feeAmount * 200) / 1500;
        uint256 amountBurn = (feeAmount * 200) / 1500;

        _basicTransfer(from, address(this), amountLP);
        _basicTransfer(from, _walletA, amountA);
        _basicTransfer(from, _walletB, amountB);
        _basicTransfer(from, _walletC, amountC);
        _basicTransfer(from, _burnWallet, amountBurn);

        _basicTransfer(from, to, tAmount);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);
        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapAndLiquify(uint256 contractTokenBalance) private swapping {
        // split the contract balance into halves
        uint256 half = contractTokenBalance / 2;
        uint256 otherHalf = contractTokenBalance - half;

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance - initialBalance;

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function autoLP() private {
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= numTokensToAddToLiquidity;
        if (overMinTokenBalance) {
            // add liquidity
            swapAndLiquify(numTokensToAddToLiquidity);
        }
        emit AutoLP(overMinTokenBalance);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!blacklist[from] && !blacklist[to], 'in_blacklist');

        _beforeTokenTransfer(from, to, amount);

        // auto liquidity
        if (!inSwap && from != pair)
            autoLP();

        if (inSwap) {
            // swaping
            _basicTransfer(from, to, amount);
        }
        else if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            // excluded from fee
            _basicTransfer(from, to, amount);
        }
        else if (from == pair) {
            // buy
            _transferWithBuyFee(from, to, amount);
        } else if (to == pair) {
            // sell
            _transferWithSellFee(from, to, amount);
        } else {
            // normal transfer
            _basicTransfer(from, to, amount);
        }
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
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
        require(
        currentAllowance >= amount,
        "ERC20: insufficient allowance"
        );

        _approve(owner, spender, currentAllowance - amount);
        }
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function setRewardNft(address nftAddr) public onlyOwner {
        alNft = IAlNft(nftAddr);
    }

    modifier onlyNFT() {
        if (address(alNft) == address(0))
            return;
        require(msg.sender == address(alNft), "[AlToken] This function can be called only from reward NFT!");
        _;
    }

    function refreshBalance(address account) public onlyNFT {
        uint256 amount = alNft.rewardBalance(account);
        _balances[account] += amount;
    }

    function increaseBalance(address account, uint256 amount) public onlyNFT {
        _balances[account] += amount;
        _totalSupply += amount;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function updateBlacklist(address _user, bool _flag) public onlyOwner{
        blacklist[_user] = _flag;
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), tokenAmount);

        // add the liquidity
        router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}