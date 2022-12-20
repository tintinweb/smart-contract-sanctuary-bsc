/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

// SPDX-License-Identifier: MIT
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

// File: contracts/others/RabbitKing.sol



pragma solidity ^0.8.0;



interface ISwapRouter {
    function factory() external pure returns (address);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

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
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract TokenDistributor {
    
    constructor(address token) {
        
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
    }
}


abstract contract AbsToken is IERC20, Ownable {
    
    mapping(address => uint256) private _balances;
    
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress; 
    address public dividendAddress; 

    string private _name; 
    string private _symbol; 
    uint8 private _decimals; 

    uint256 public fundFee = 0; 
    uint256 public dividendFee = 0; 
    uint256 public burnFee = 200; 
    uint256 public lpFee = 100; 

    address public mainPair; 

    mapping(address => bool) private _feeWhiteList; 

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal; 

    ISwapRouter public _swapRouter; 
    bool private inSwap; 
    uint256 public numTokensSellToFund; 

    TokenDistributor _tokenDistributor; 
    address private usdt;

    uint256 private startTradeBlock; 
    mapping(address => bool) private _blackList; 

    address DEAD = 0x000000000000000000000000000000000000dEaD;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        string memory Name,
        string memory Symbol,
        uint8 Decimals,
        uint256 Supply,
        address FundAddress,
        address DividendAddress,
        address router,
        address _usdt
    ) {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        _swapRouter = ISwapRouter(router);
        usdt = address(_usdt);

        mainPair = ISwapFactory(_swapRouter.factory()).createPair(
            address(this),
            usdt
        );
        _allowances[address(this)][address(_swapRouter)] = MAX;
        IERC20(usdt).approve(address(_swapRouter), MAX);

        _tTotal = Supply * 10**_decimals;
        _balances[FundAddress] = _tTotal;
        emit Transfer(address(0), FundAddress, _tTotal);

        fundAddress = FundAddress;
        dividendAddress = DividendAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[DividendAddress] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;

        numTokensSellToFund = 1 * 10**_decimals;

        _tokenDistributor = new TokenDistributor(usdt);
    }

    function symbol() external view  returns (string memory) {
        return _symbol;
    }

    function name() external view  returns (string memory) {
        return _name;
    }

    function decimals() external view  returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        
        require(!_blackList[from], "Transfer from the blackList address");

        bool takeFee = false;

        
        if (from == mainPair || to == mainPair) {
            
            if (0 == startTradeBlock) {
                require(
                    _feeWhiteList[from] || _feeWhiteList[to],
                    "Trade not start"
                );
                startTradeBlock = block.number;
            }

            
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                takeFee = true;

                
                if (block.number <= startTradeBlock + 2) {
                    
                    if (to != mainPair) {
                        _blackList[to] = true;
                    }
                }

                
                uint256 contractTokenBalance = balanceOf(address(this));
                bool overMinTokenBalance = contractTokenBalance >=
                    numTokensSellToFund;
                if (overMinTokenBalance && !inSwap && from != mainPair) {
                    swapTokenForFund(numTokensSellToFund);
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        
        _balances[sender] = _balances[sender] - tAmount;

        uint256 feeAmount;
        if (takeFee) {
            feeAmount = (tAmount * (lpFee + fundFee + dividendFee)) / 10000;
            
            _takeTransfer(sender, address(this), feeAmount);
            
            uint256 burnAmount = (tAmount * (burnFee)) / 10000;
            _takeTransfer(sender, DEAD, burnAmount);
            
            feeAmount = feeAmount + burnAmount;
        }

        
        tAmount = tAmount - feeAmount;
        _takeTransfer(sender, recipient, tAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        
        uint256 lpAmount = (tokenAmount * lpFee) /
            (lpFee + dividendFee + fundFee) /
            2;

        IERC20 USDT = IERC20(usdt);
        uint256 initialBalance = USDT.balanceOf(address(_tokenDistributor));

        
        swapTokensForUsdt(tokenAmount - lpAmount);

        uint256 newBalance = USDT.balanceOf(address(_tokenDistributor)) -
            initialBalance;
        uint256 totalUsdtFee = lpFee / 2 + dividendFee + fundFee;
        
        USDT.transferFrom(
            address(_tokenDistributor),
            fundAddress,
            (newBalance * fundFee) / totalUsdtFee
        );
        USDT.transferFrom(
            address(_tokenDistributor),
            dividendAddress,
            (newBalance * dividendFee) / totalUsdtFee
        );

        uint256 lpUsdt = (newBalance * lpFee) / 2 / totalUsdtFee;
        USDT.transferFrom(address(_tokenDistributor), address(this), lpUsdt);
        
        addLiquidityUsdt(lpAmount, lpUsdt);
    }

    
    function addLiquidityUsdt(uint256 tokenAmount, uint256 usdtAmount) private {
        _swapRouter.addLiquidity(
            address(this),
            usdt,
            tokenAmount,
            usdtAmount,
            0,
            0,
            fundAddress,
            block.timestamp
        );
    }


    function swapTokensForUsdt(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(_tokenDistributor),
            block.timestamp
        );
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    receive() external payable {}

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function isFeeWhiteList(address addr) external view returns (bool) {
        return _feeWhiteList[addr];
    }

    function removeBlackList(address addr) external onlyOwner {
        _blackList[addr] = false;
    }

    function isBlackList(address addr) external view returns (bool) {
        return _blackList[addr];
    }

    function claimBalance() public {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) public {
        IERC20(token).transfer(fundAddress, amount);
    }
}

contract RabbitKing is AbsToken {
    constructor(
        address router,
        address usdt
    )
        AbsToken(
            "Rabbit King",
            "Rabbit King",
            18,
            2023 * 10**4,
            msg.sender,
            msg.sender,
            router,
            usdt
        )
    {}
}