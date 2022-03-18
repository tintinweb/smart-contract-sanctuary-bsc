// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

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

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

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


contract Ownable {
    address public _owner;


    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
   
    function renounceOwnership() public  onlyOwner {
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public  onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _owner = newOwner;
    }
}


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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


contract BYDK is Context, Ownable, IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => Relation) private _relation;
    mapping(address => bool) private _whiteList;
    mapping(address => bool) private _blacklist;
    mapping(address => bool) private _braveTroopsList;

    uint8 private _decimals;
    string private _name;
    string private _symbol;

    uint256 private _totalSupply;
    uint256 private _maxTxAmount;
    uint256 public directRate;
    uint256 public indiretRate;
    uint256 public blackRate;
    uint256 public sharetRate;
    uint256 public liquifyRate;
    uint256 public biddingRate;
    uint256 public lpShareRate;
    uint256 public burnMinAmount;
    uint256 public denominator;
    uint256 public numTokensSellToAddToLiquidity;
    uint256 public limit;

    address public usdt;

    address public fundAddress = 0xD986Cfb4c7C370A6A81e24032d61836744D63647;
    address public biddingAddress = 0x144255298efF5AFd8000B9fba74e4a4F2aFD6b20;
    address public shareAddress = 0x2c0b21b11E24EEA70c01208C6e78b6929ec7A158;
    address public lpShareAddress = 0x71E290CF4ebfd4534ee8775dCDFecE8313EAB50a;

    IUniswapV2Router02 public immutable uniswapV2Router;
    IUniswapV2Pair public immutable uniswapV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    struct Relation {
        address one;
        address two;
    }

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
    event WithdrawlUSDT(address sender, uint256 amount);
    event WithdrawlERC20(address sender, uint256 amount);

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(address router_, address usdt_) {
        _owner = msg.sender;
        _name = "BY DK TOKEN";
        _symbol = "BYDK";
        _decimals = 18;
        _totalSupply = 2000000*10**_decimals;
        burnMinAmount = 10000*10**_decimals;
        _balances[_owner] = _totalSupply;
        numTokensSellToAddToLiquidity = 1000*10**_decimals;
        _maxTxAmount = 5000*10**_decimals;
        limit = 1*10**_decimals;

        directRate = 10;
        indiretRate = 10;
        blackRate = 30;
        sharetRate = 20;
        lpShareRate = 30;
        liquifyRate = 30; // 流动性费用
        biddingRate = 20;
        denominator = 1000; // 分母

        _whiteList[address(this)] = true;

        usdt = usdt_;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router_);
        uniswapV2Pair = IUniswapV2Pair(IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), usdt_));
        uniswapV2Router = _uniswapV2Router;

        emit Transfer(address(0), _owner, _totalSupply);
    }

    receive() external payable {}

    function name() public view virtual  returns (string memory) {
        return _name;
    }

    function symbol() public view virtual  returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual  returns (uint8) {
        return _decimals;
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
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        // 拉入黑名单的用户无法转入转出和买入卖出
        require(!getInBlacklist(sender), "ERC20: Blacklist cannot transfer");
        require(!getInBlacklist(recipient), "ERC20: Blacklist cannot accept transfer");

        // 貔貅黑名单用户无法转出、购买
        require(!getInBraveTroops(sender), "ERC20: User cannot transfer out");

        require(amount > 0, "Transfer amount must be greater than zero");

        // 不存在黑名单中的用户有转账限制
        if(!getInWhiteList(sender)){
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }
           
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        if (senderBalance == amount) {
            amount -= 10;
        }

        // 添加流动性
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (overMinTokenBalance && !inSwapAndLiquify && sender != address(uniswapV2Pair) && swapAndLiquifyEnabled) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            swapAndLiquify(contractTokenBalance);
        }

        _balances[sender] = senderBalance.sub(amount);

        if (getInWhiteList(sender) || getInWhiteList(recipient) || recipient == address(uniswapV2Pair) || totalSupply() <= burnMinAmount){ // 取消手续费
           _transferToken(sender, recipient, amount);
        } else { // 手续费分配
            uint256 recipientAmount = _transferRelationToken(recipient,amount);
            _transferToken(sender, recipient, recipientAmount);
        }

        // 发送或者接受是交易对地址无法创建关系
        if (recipient != address(uniswapV2Pair) && sender != address(uniswapV2Pair)){
            if (amount >= limit){// 创建关系时必须要满足最低转账限制才能创建成功
                _relationEstablish(sender, recipient);
            }
        }
    }


    function _transferRelationToken(address recipient,uint256 amount) internal returns(uint256 recipientAmount){
        uint256 directPushFree = amount.mul(directRate).div(denominator);
        uint256 indirectPushFree = amount.mul(indiretRate).div(denominator);
        // 一二代手续费
        _relationTransfer(recipient, directPushFree, indirectPushFree);
        {
            uint256 liquifyFee = amount.mul(liquifyRate).div(denominator);
            uint256 blackHoleFree = amount.mul(blackRate).div(denominator);
            uint256 shareFree = amount.mul(sharetRate).div(denominator);
            uint256 biddingFree = amount.mul(biddingRate).div(denominator);
            uint256 lpShareFee = amount.mul(lpShareRate).div(denominator);
            _transferToken(recipient, address(this), liquifyFee);  // 回流到交易对
            _burn(recipient,  blackHoleFree);                      // 黑洞销毁
            _transferToken(recipient, shareAddress, shareFree);    // 持币分红
            _transferToken(recipient, biddingAddress, biddingFree);// 竞赛分红
            _transferToken(recipient, lpShareAddress, lpShareFee); // lp回流分红
            recipientAmount = amount.sub(directPushFree + indirectPushFree + blackHoleFree + shareFree + liquifyFee + biddingFree + lpShareFee);
        }
    }

    function _relationEstablish(address sender, address recipient) internal {
        if (_relation[recipient].one == address(0)){
            _relation[recipient].one = sender;
            _relation[recipient].two = _relation[sender].one;
        }
    }

    function _relationTransfer(address recipient, uint256 directPushFree, uint256 indirectPushFree) internal {
        if (_relation[recipient].one != address(0)){
            _transferToken(recipient, _relation[recipient].one, directPushFree);
        } else {
            _burn(recipient, directPushFree + indirectPushFree);
            return;
        }

        if (_relation[recipient].two != address(0)){
            _transferToken(recipient, _relation[recipient].two, indirectPushFree);
        }else {
            _burn(recipient, indirectPushFree);
        }
    }

    function _transferToken(address sender, address recipient, uint256 amount) internal {
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burn(address account, uint256 value) internal {
        _totalSupply = _totalSupply.sub(value);
        emit Transfer(account, address(0), value);
    }

    function burn(address account, uint256 value) external  {
        _balances[account] = _balances[account].sub(value);
        _burn(account, value);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current usdt balance.
        // this is so that we can capture exactly the amount of usdt that the
        // swap creates, and not make the liquidity event include any usdt that
        // has been manually sent to the contract
        uint256 initialBalance = IERC20(usdt).balanceOf(address(this));

        // swap tokens for usdt
        swapTokensForToken(half);

        // how much usdt did we just swap into?
        uint256 newBalance = IERC20(usdt).balanceOf(address(this)).sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForToken(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> usdt
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uint256 initialBalance = IERC20(usdt).balanceOf(_owner);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of usdt
            path,
            _owner,
            block.timestamp
        );

        uint256 newBalance = IERC20(usdt).balanceOf(_owner).sub(initialBalance);

        IERC20(usdt).transferFrom(_owner, address(this), newBalance); // 合约创建完成后_owner必须要先授权给合约usdt
    }

    function addLiquidity(uint256 token0Amount, uint256 token1Amount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), token0Amount);
        IERC20(usdt).approve(address(uniswapV2Router), token1Amount);

        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(this),
            usdt,
            token0Amount,
            token1Amount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            _owner,
            block.timestamp
        );
    }

    function setTransferFee(
        uint256 directFee_, 
        uint256 indirectFee_,
        uint256 lpShareRate_,
        uint256 blackFee_, 
        uint256 shareFee_, 
        uint256 liquifyFee_, 
        uint256 biddingFee_,
        uint256 denominator_) external onlyOwner 
    {
        directRate = directFee_;
        indiretRate = indirectFee_;
        lpShareRate = lpShareRate_;
        blackRate = blackFee_;
        sharetRate = shareFee_;
        liquifyRate = liquifyFee_;
        biddingRate = biddingFee_;
        denominator = denominator_;
    }

    function includeWhiteList(address account) external onlyOwner{
        _whiteList[account] = true;
    }

    function excludeWhiteList(address account) external onlyOwner{
        _whiteList[account] = false;
    }

    function getInWhiteList(address account) public view returns(bool){
        return _whiteList[account];
    }

    function includeBlacklist(address account) external onlyOwner {
        _blacklist[account] = true;
    }

    function excludeBlacklist(address account) external onlyOwner {
        _blacklist[account] = false;
    }

    function getInBlacklist(address account) public view returns(bool) {
        return _blacklist[account];
    }

    function includeBraveTroops(address account) external onlyOwner{
        _braveTroopsList[account] = true;
    }

    function excludeBraveTroops(address account) external onlyOwner{
        _braveTroopsList[account] = false;
    }

    function getInBraveTroops(address account) public view returns(bool){
        return _braveTroopsList[account];
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
    function setNumTokensSellToAddToLiquidity(uint256 swapNumber) public onlyOwner {
        numTokensSellToAddToLiquidity = swapNumber * 10 ** _decimals;
    }

    function setBurnMinAmount(uint256 minNumber) public onlyOwner {
        burnMinAmount = minNumber * 10 ** _decimals;
    }

    function setRelationTransferLimit(uint256 limit_) public onlyOwner {
        limit = limit_ * 10 ** _decimals;
    }

    function setMaxTransferLimit(uint256 limit_) public onlyOwner {
        _maxTxAmount = limit_ * 10 ** _decimals;
    }

    function setCollectFeeAddress(address fundAddress_, address biddingAddress_, address shareAddress_, address lpShareAddress_) public onlyOwner{
        fundAddress = fundAddress_;
        biddingAddress = biddingAddress_;
        shareAddress = shareAddress_;
        lpShareAddress = lpShareAddress_;
    }

    function withdrawlUSDT() external onlyOwner{
        uint256 usdtBalance = IERC20(usdt).balanceOf(address(this));
        require(usdtBalance > 0, "BEP20: Balance is not enough");
        IERC20(usdt).transfer(msg.sender, usdtBalance);
        emit WithdrawlUSDT(msg.sender, usdtBalance);
    }

    function withdrawlERC20() external onlyOwner{
        uint256 balance = balanceOf(address(this));
        require(balance > 10, "BEP20: Balance is not enough");
        _approve(address(this), msg.sender, balance);
        transferFrom(address(this), msg.sender, balance);
        emit WithdrawlERC20(msg.sender, balance);
    }
}