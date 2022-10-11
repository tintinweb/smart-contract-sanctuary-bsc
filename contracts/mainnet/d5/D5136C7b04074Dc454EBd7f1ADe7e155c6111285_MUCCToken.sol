pragma solidity 0.6.12;

import './SafeMath.sol';
import './IBEP20.sol';
import './Ownable.sol';


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WDCC() external pure returns (address);

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



// pragma solidity >=0.6.2;

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

contract MUCCTokenCallbackSinglePool is Ownable {
   using SafeMath for uint256;

   IUniswapV2Router02 public router;
   address public muccTokenAddress;
   address public toAddress;
   address public usdtAddress;
   address public uniswapV2PairUsdt;

   uint256 public  usdtRewardThreshlod; //100u


   bool inSwapAndLiquify;
   int public locki = 0;
   modifier lockTheSwap() {
       inSwapAndLiquify = true;
       locki = locki + 1;
       _;
       inSwapAndLiquify = false;
   }

   constructor (
       address _router,
       address _muccToken,
       address _usdtAddress,
       address _toAddress,
       address _uniswapV2PairUsdt
   ) public {
       router = IUniswapV2Router02(_router);
       muccTokenAddress = _muccToken;
       usdtAddress = _usdtAddress;
       toAddress = _toAddress;
       uniswapV2PairUsdt = _uniswapV2PairUsdt;
       usdtRewardThreshlod = 500 * (10 ** uint256(IBEP20(usdtAddress).decimals()));
       
//        _usdtRewardThreshlod = 1 * (10 ** uint256(IBEP20(usdtAddress).decimals()));
   }


   function getNewPrice() public view returns (uint256 newPrice){
       if (IBEP20(uniswapV2PairUsdt).totalSupply() > 0 && IBEP20(usdtAddress).balanceOf(uniswapV2PairUsdt) > 10 * 10 ** 18) {
           address[] memory t = new address[](2);

           t[0] = muccTokenAddress;
           t[1] = usdtAddress;

           uint256[] memory amounts = router.getAmountsOut(1 * (10 ** uint256(IBEP20(muccTokenAddress).decimals())), t);
           newPrice = amounts[1];
       }
   }

   function setOnSwap(bool _swapSwitch) public onlyOwner {
       swapSwitch = _swapSwitch;

   }

   bool public  swapSwitch = true;


   function swapAndLiquify() public {
       if (!inSwapAndLiquify) {
           uint256 contractTokenBalance = IBEP20(muccTokenAddress).balanceOf(address(this));

           uint256 newPrice = getNewPrice();

           uint256 tokenUsdtValue = contractTokenBalance.mul(newPrice).div(10 ** uint256(IBEP20(muccTokenAddress).decimals()));

           // split the contract balance into halves
           if (tokenUsdtValue > usdtRewardThreshlod) {

               if (swapSwitch) {
                    uint256 initialBalanceUsdt = IBEP20(usdtAddress).balanceOf(address(this));
                    swapTokensForUsdt(contractTokenBalance);
                    uint256 usdtBalanceAll = IBEP20(usdtAddress).balanceOf(address(this));
                    uint256 newUsdtBalance = usdtBalanceAll.sub(initialBalanceUsdt);
                    if(newUsdtBalance > 0){
                        uint256 usdtBalanceFee = newUsdtBalance.div(7); //7分之一给fee
                        IBEP20(usdtAddress).transfer(toAddress, usdtBalanceFee);
                        // toAddress
                        
                        uint256 usdtRewardAssign = IBEP20(usdtAddress).balanceOf(address(this));
                        if(usdtRewardAssign>0){
                            IBEP20(usdtAddress).transfer(muccTokenAddress, usdtRewardAssign);
                            MUCCToken(muccTokenAddress).assignUsdtRewardFromCallback(usdtRewardAssign);
                        }
                    }
               }
               
           }
       }
   }


   function swapTokensForUsdt(
       uint256 tokenAmount
   ) private lockTheSwap {
       // generate the uniswap pair path of token -> weth
       address[] memory path = new address[](2);
       path[0] = address(muccTokenAddress);
       path[1] = usdtAddress;
       IBEP20(address(muccTokenAddress)).approve(address(router), tokenAmount);
       // make the swap
       router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
           tokenAmount,
           0, // accept any amount of ETH
           path,
           address(this),
           block.timestamp
       );
   }
  
   function setUsdtRewardThreshlod(uint256 _usdtRewardThreshlod) external onlyOwner {
       usdtRewardThreshlod = _usdtRewardThreshlod;
   }

   function setToAddress(address _toAddress) external onlyOwner {
       toAddress = _toAddress;
   }

   function transferToken(address token, address to) public onlyOwner {
       require(token != address(0), 'CallBack::transferToken::TOKEN_ZERO_ADDRESS');
       require(to != address(0), 'CallBack::transferToken::TO_ZERO_ADDRESS');
       uint256 newBalanceToken0 = IBEP20(token).balanceOf(address(this));

       IBEP20(token).transfer(to, newBalanceToken0);
   }


}

contract MUCCToken is IBEP20 {
    using SafeMath for uint256;

    mapping(address => uint256) internal _tOwned;
    mapping(address => mapping(address => uint256)) internal _allowances;

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    uint256 internal _tTotal;

    address public _owner;
    address public foundationAddress = 0xcd0a64f01ECDF39BbCc09Da702Cc639102f752b9;
    address public feeAddress = 0x50dbBbBe09A4C52470458169767058Ee30932a5A;
    uint public feeRate = 7;

    uint public foundationRate = 1;  //dao
    uint public blackHoleRate = 1;
    uint public addLiquidRate = 1;
    uint public  stakeRewardRate = 35; //div 10
    uint public tailBonusRate = 5; // div 10

    address public uniswapV2PairUsdt;

    address public lastBuyAddress = address(0);
    uint256 public lastBuyTime = 0;

    uint256 public _supply = 14905600;

    address burnAddress = address(0);
    mapping(address => bool) public blackList;


    mapping(address => bool) public uniswapV2PairList;
    bool public useWhiteListSwith = true;

    address public  callback;
    MUCCTokenCallbackSinglePool bfavTokenCallbackSinglePool;
    IUniswapV2Router02 public router;
      address public usdtAddress = 0x55d398326f99059fF775485246999027B3197955; //TODO idc 
    // address public usdtAddress = 0xc9d9467a1D5Bf5736195059145d6aE924B69e209;
    

    uint256 internal _minSupply;
    uint256 _burnedAmount;

    address[] public nodeList;
    mapping(address => uint) public nodeRewardMap;
    // mapping(address => bool) public nodeListPushed;
    mapping(address => bool) public noFeeWhiteList;
    mapping(address => bool) public noNodeList;
    // mapping(address => bool) public whiteList;
    // bool public start ;
    mapping(address => UserInfo) public userInfo;

    uint256 public  distributePos = 0;
    uint256 public  distributeLimitOneTime = 5; //TODO
    uint256 public  muccRewardThreshlod; //10000

    uint256 public  totalHoldForReward;

    struct UserInfo {
        uint256 nodePower;//直推算力
        uint256 nodeDebt;//节点收益负载
    }

    struct RewardNodePool {
        uint256 totalReward;//当前收益总量
        uint256 lastReward;//上次收益
        uint256 accRewardPerShare;//每股收益
    }

    RewardNodePool public rewardNodePool;

    event blackUser(address indexed from, address indexed to, uint value);
    event setUniswapPairListEvent(address indexed pairAddress, bool indexed isPair);
    event setBlackListEvent(address indexed pairAddress, bool indexed isPair);
    event setNoFeeWhiteListEvent(address indexed pairAddress, bool indexed isPair);
    event setFeeRateEvent(uint indexed _feeRate);

    modifier onlyOwner() {
        require(msg.sender == _owner, "admin: wut?");
        _;
    }

    //最后销毁至3000枚。
    constructor (
        // address _usdtAddress,
        address _router
    ) public {
        router = IUniswapV2Router02(_router);
//router test  0xce3a34b6b9b092f0f8c88063afe4aaa784a1a1a3
//router id   0x10ED43C718714eb63d5aA57B78B54704E256024E
        // usdtAddress = _usdtAddress;
        _decimals = 18;
        _tTotal = _supply * (10 ** uint256(_decimals));
        _name = "MUCC";
        _symbol = "MUCC";

        _tOwned[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tOwned[msg.sender]);

        _minSupply = 3000 * (10 ** uint256(decimals()));

       
        uniswapV2PairUsdt = createPair(usdtAddress);  //usdt
        
        // createPair(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);//wbnb
        // createPair(0xe0DF6C2738Ec5D9f46B065596B39Db8D2c51d828); //busd

        createPair(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);//wbnb  - idc
        createPair(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); //busd  - idc

        _owner = msg.sender;
       bfavTokenCallbackSinglePool = new MUCCTokenCallbackSinglePool(address(router), address(this), usdtAddress, feeAddress, uniswapV2PairUsdt);
       callback = address(bfavTokenCallbackSinglePool);
       noFeeWhiteList[0xba082f065Ca89e92e51bA57afE55f6B1E27b1edf] = true;
       noFeeWhiteList[msg.sender] = true;
       noFeeWhiteList[address(this)] = true;
       noFeeWhiteList[callback] = true;
       noNodeList[0xba082f065Ca89e92e51bA57afE55f6B1E27b1edf] = true;
       noNodeList[msg.sender] = true;
       noNodeList[address(this)] = true;
       noNodeList[callback] = true;

    //    whiteList[0xba082f065Ca89e92e51bA57afE55f6B1E27b1edf] = true;
    //    whiteList[msg.sender] = true;

    //    start = false;

        muccRewardThreshlod = 10000 * (10 ** uint256(decimals()));
    }

    function createPair(address _pairBaseAddress) private returns(address) {
        address _uniswapV2Pair = IUniswapV2Factory(router.factory())
        .createPair(address(this), _pairBaseAddress);

        uniswapV2PairList[_uniswapV2Pair] = true;
        return _uniswapV2Pair;
    }

    function minSupply() public view returns (uint256) {
        return _minSupply;
    }

    function transferOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "newOwner is zero address");
        _owner = newOwner;
    }

    function getNodeList() view external returns(address[] memory){
        return  nodeList;
    }

   function setMUCCTokenCallback(address _bfavTokenCallback) external onlyOwner {
       callback = _bfavTokenCallback;
   }
   function setUsdtRewardThreshlod(uint256 _usdtRewardThreshlod) external onlyOwner {
       bfavTokenCallbackSinglePool.setUsdtRewardThreshlod(_usdtRewardThreshlod);
   }
    function setMuccRewardThreshlod(uint256 _muccRewardThreshlod) external onlyOwner {
       muccRewardThreshlod = _muccRewardThreshlod;
   }

    function setUniswapPairList(address pairAddress, bool isPair) external onlyOwner {
        require(pairAddress != address(0), "pairAddress is zero address");
        uniswapV2PairList[pairAddress] = isPair;
        emit setUniswapPairListEvent(  pairAddress,  isPair);
    }

    function setBlackList(address userAddress, bool isBlock) external onlyOwner {
        require(userAddress != address(0), "userAddress is zero address");
        blackList[userAddress] = isBlock;
        emit setBlackListEvent(  userAddress,  isBlock);
    }
    function setNoFeeWhiteList(address userAddress, bool isWhiteList) external onlyOwner {
        require(userAddress != address(0), "userAddress is zero address");
        noFeeWhiteList[userAddress] = isWhiteList;
        emit setNoFeeWhiteListEvent(  userAddress,  isWhiteList);
    }
    function setNoNodeList(address userAddress, bool isNode) external onlyOwner {
        require(userAddress != address(0), "userAddress is zero address");
        noNodeList[userAddress] = isNode;
    }
    // function setWhiteList(address userAddress, bool isWhite) external onlyOwner {
    //     require(userAddress != address(0), "userAddress is zero address");
    //     whiteList[userAddress] = isWhite;
    // }
    // function setStart(bool _start) external onlyOwner {
    //     start = _start;
    // }
    function setFeeRate(uint _feeRate) external onlyOwner {
        feeRate = _feeRate;
        emit setFeeRateEvent(  _feeRate);
    }

    function setDistributeLimitOneTime(uint _distributeLimitOneTime) external onlyOwner {
        distributeLimitOneTime = _distributeLimitOneTime;
    }

    function setRouter(address _router) external onlyOwner {
        router = IUniswapV2Router02(_router);
        // emit setRouterEvent(  _router);
    }
    
    function setNodeReward(address nodeAddress,uint _flag) external onlyOwner {
        nodeRewardMap[nodeAddress] = _flag;
        // emit setRouterEvent(  _router);
    }

    function setFeeAddress(address _feeAddress) external onlyOwner {
        feeAddress = _feeAddress;
        bfavTokenCallbackSinglePool.setToAddress(feeAddress);
    }

    function setOnSwap(bool _swapSwitch) public onlyOwner {
        bfavTokenCallbackSinglePool.setOnSwap(_swapSwitch);
    }

    function transferCallbackToken(address token, address to) external onlyOwner {
        bfavTokenCallbackSinglePool.transferToken(token, to);
    }

   function transferToken(address token, address to) public onlyOwner {
       require(token != address(0), 'MuccToken::transferToken::TOKEN_ZERO_ADDRESS');
       require(to != address(0), 'MuccToken::transferToken::TO_ZERO_ADDRESS');
       uint256 newBalanceToken0 = IBEP20(token).balanceOf(address(this));

       IBEP20(token).transfer(to, newBalanceToken0);
   }

    function setFoundationAddress(address _foundationAddress) external onlyOwner {
        foundationAddress = _foundationAddress;
    }

    function burnedAmount() public view returns (uint256) {
        return _burnedAmount;
    }

    function setFoundationRate(uint _foundationRate) external onlyOwner {
        foundationRate = _foundationRate;
    }

    function name() public override view returns (string memory) {
        return _name;
    }

    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }


    function getOwner() public view override returns (address){
        return _owner;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        address msgSender = msg.sender;
        _approve(sender, msgSender, _allowances[sender][msgSender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }


    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function calculateFee(uint256 _amount) public view returns (uint256) {
        return _amount.mul(uint256(feeRate)).div(
            10 ** 2
        );
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(address(callback) != address(0), "callback can not be zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(feeRate > 0, "fee rate must be greater than zero");
        uint256 leftAmount = _tTotal.sub(_burnedAmount);

        require(!blackList[from] && !blackList[to], "black transfer not allowed");

        // require(whiteList[tx.origin] || start, "transfer not allowed");

        uint256 fee = 0;

        if(lastBuyTime>0 && lastBuyAddress != address(0) && _tOwned[address(this)]>0 ){
            uint256 diffTime = block.timestamp - lastBuyTime;
            // TODO if(diffTime >= 20*60){
            if(diffTime >= 20*60){
                uint256 tailBonusReward = _tOwned[address(this)].div(2);
                _tOwned[address(this)] = _tOwned[address(this)].sub(tailBonusReward);
                _tOwned[lastBuyAddress] = _tOwned[lastBuyAddress].add(tailBonusReward);
                emit Transfer(address(this),lastBuyAddress, tailBonusReward);

                lastBuyTime = 0;
                lastBuyAddress = address(0);
            }
        }
            
            // sell  or  buy
            if ((uniswapV2PairList[to] || uniswapV2PairList[from]) && 
                 from != callback && to != callback
                && noFeeWhiteList[tx.origin] != true
                ) {

                fee = calculateFee(amount);
                if (fee > 0) {
                    // address  uniswapV2Pair = from;
                    if(leftAmount > _minSupply && leftAmount > fee){
                        uint256 leftAmountSubFee = leftAmount.sub(fee);
                        if (leftAmountSubFee < _minSupply) {
                            fee = leftAmount.sub(_minSupply);
                        }
                    }

                    uint256 foundationAmount = fee.mul(foundationRate).div(feeRate);

                    _tOwned[foundationAddress] = _tOwned[foundationAddress].add(foundationAmount);
                    emit Transfer(from, foundationAddress, foundationAmount);

                    if(leftAmount > _minSupply ){
                        uint256 blackHoleAmount = fee.mul(blackHoleRate).div(feeRate);
                        _tOwned[burnAddress] = _tOwned[burnAddress].add(blackHoleAmount);
                        _burnedAmount = _burnedAmount.add(blackHoleAmount);
                        emit Transfer(from, burnAddress, blackHoleAmount);
                    }

                    uint256 addLiquidAmount = fee.mul(addLiquidRate).div(feeRate);
                    _tOwned[uniswapV2PairUsdt] = _tOwned[uniswapV2PairUsdt].add(addLiquidAmount);
                    emit Transfer(from, uniswapV2PairUsdt, addLiquidAmount);

                    uint256 stakeRewardAmount = fee.mul(stakeRewardRate).div(10).div(feeRate);
                    _tOwned[address(callback)] = _tOwned[address(callback)].add(stakeRewardAmount);
                    emit Transfer(from, address(callback), stakeRewardAmount);

                    uint256 tailBonusAmount = fee.mul(tailBonusRate).div(10).div(feeRate);
                    _tOwned[address(this)] = _tOwned[address(this)].add(tailBonusAmount);
                    emit Transfer(from, address(this), tailBonusAmount);

                    // add liquidate   / buy
                    if( uniswapV2PairList[from]
                    ){
                        uint256 newPrice = getNewPrice();
                        uint256 newValue = newPrice.mul(amount).div(10 ** 18); 

                        if(newValue >  (10 ** uint256(IBEP20(usdtAddress).decimals()))){
                            lastBuyAddress = to;
                            lastBuyTime = block.timestamp;
                        }
                    }

                } else {
                    fee = 0;
                }
            }
        // enough  liquid
        if (IBEP20(uniswapV2PairUsdt).totalSupply() > 0 && balanceOf(uniswapV2PairUsdt) > 10 * 10 ** 18) {
            //&& !uniswapV2PairList[to]  正在分红的时候不触发，免得usdt 累计  && distributePos == 0  通过defi的方式可以不用这个限制
            if (!uniswapV2PairList[from] &&  balanceOf(address(callback)) > 0 && address(callback) != address(0)) {
                MUCCTokenCallbackSinglePool(address(callback)).swapAndLiquify();
            }

        }

        uint acceptAmount = amount - fee ;

        uint256 originFromBalance = _tOwned[from]; 
        uint256 originToBalance = _tOwned[to]; 

        _tOwned[from] = _tOwned[from].sub(amount);
        _tOwned[to] = _tOwned[to].add(acceptAmount);
        emit Transfer(from, to, acceptAmount);

            uint256 usdtBalanceAll = IBEP20(usdtAddress).balanceOf(address(this));

            // 避免callback
            if( usdtBalanceAll> 0 && totalHoldForReward >0
                && from != callback && to != callback
                && from != address(this) && to != address(this)
            )
            {
                uint256 usdtCurrent = usdtBalanceAll;
                uint256 posTmp =distributePos;
                uint256 posCurrentAmount;
                bool isBreak = false;
                for(;posTmp < nodeList.length && posCurrentAmount< (distributeLimitOneTime - 1) ; ){
                    address nodeAddress = nodeList[posTmp];
                    if(nodeRewardMap[nodeAddress] == 1){
                        // uint256 usdtAssign = usdtBalanceAll.mul(balanceOf(nodeAddress)).div(totalHoldForReward);
                        UserInfo storage nodeUserInfoAssign = userInfo[nodeAddress];
                        updateNodePool(0);
                        uint256 pendingNodeUser ;
                        if (nodeUserInfoAssign.nodePower > 0) {
                             pendingNodeUser = nodeUserInfoAssign.nodePower.mul(rewardNodePool.accRewardPerShare).div(1e12).sub(nodeUserInfoAssign.nodeDebt);
                        }
                        nodeUserInfoAssign.nodeDebt = nodeUserInfoAssign.nodePower.mul(rewardNodePool.accRewardPerShare).div(1e12);
                        
                        usdtCurrent = IBEP20(usdtAddress).balanceOf(address(this));
                        if(usdtCurrent==0){
                            isBreak = true;
                            break;
                        }
                        posCurrentAmount = posTmp - distributePos;
                        if(pendingNodeUser>0){
                            IBEP20(usdtAddress).transfer(nodeAddress, 
                                pendingNodeUser > usdtCurrent? usdtCurrent: pendingNodeUser);
                        }
                    }
                    posTmp = posTmp+1;
                }
                distributePos = posTmp;

                if(isBreak || posTmp >= nodeList.length ){
                    distributePos = 0;
                }
            }
        if(!uniswapV2PairList[to]  && noNodeList[to] != true  ){
            
            if(_tOwned[to] >= muccRewardThreshlod){
                nodeRewardMap[to]  = 1;
            }
            if( nodeRewardMap[to] == 1){
                uint originToPosition = nodeRewardMap[to]  ;
                updateNodePool(0);
                UserInfo storage nodeUserInfoTo = userInfo[to];
                if(originToPosition == 0 || originToPosition == 2 ){
                    // if(nodeListPushed[to]!=true){
                    if(originToPosition == 0){ 
                        nodeList.push(to);
                    }
                        // nodeListPushed[to] =true;
                    // }
                    totalHoldForReward = totalHoldForReward.add(_tOwned[to]);
                } else if(originToPosition == 1 ){
                    uint256 usdtPendingTo = nodeUserInfoTo.nodePower.mul(rewardNodePool.accRewardPerShare).div(1e12).sub(nodeUserInfoTo.nodeDebt);
                    if(usdtPendingTo>0){
                        uint256 usdtCurrentTo = IBEP20(usdtAddress).balanceOf(address(this));
                        //from 持仓减持，给他结算收益
                        IBEP20(usdtAddress).transfer(to, 
                                    usdtPendingTo > usdtCurrentTo? usdtCurrentTo: usdtPendingTo);
                    }
                    if(totalHoldForReward>=originToBalance){
                        totalHoldForReward = totalHoldForReward.sub(originToBalance);
                    }
                    totalHoldForReward = totalHoldForReward.add(_tOwned[to]);
                }


                nodeUserInfoTo.nodePower = _tOwned[to];
                nodeUserInfoTo.nodeDebt = nodeUserInfoTo.nodePower.mul(rewardNodePool.accRewardPerShare).div(1e12);
            }
        }
        if(!uniswapV2PairList[from] && noNodeList[from] != true ) {
            updateNodePool(0);
            // bool originFromPosition = nodeRewardMap[from]  ;
            if(totalHoldForReward>=originFromBalance){
                totalHoldForReward = totalHoldForReward.sub(originFromBalance);
            }
            // 持有≥10000枚有效持仓 分红
            if(_tOwned[from] < muccRewardThreshlod){
                nodeRewardMap[from]  = 2;
            }else{
                totalHoldForReward = totalHoldForReward.add(_tOwned[from]);
                // if(totalHoldForReward> _tTotal){
                //     totalHoldForReward = _tTotal;
                // }
            }
            UserInfo storage nodeUserInfoFrom = userInfo[from];


            if (nodeUserInfoFrom.nodePower > 0) {
                uint256 usdtPendingFrom = nodeUserInfoFrom.nodePower.mul(rewardNodePool.accRewardPerShare).div(1e12).sub(nodeUserInfoFrom.nodeDebt);
                if(usdtPendingFrom>0){
                    uint256 usdtCurrentFrom = IBEP20(usdtAddress).balanceOf(address(this));
                    //from 持仓减持，给他结算收益
                    IBEP20(usdtAddress).transfer(from, 
                                usdtPendingFrom > usdtCurrentFrom? usdtCurrentFrom: usdtPendingFrom);
                }
            }

            nodeUserInfoFrom.nodePower = _tOwned[from];
            nodeUserInfoFrom.nodeDebt = nodeUserInfoFrom.nodePower.mul(rewardNodePool.accRewardPerShare).div(1e12);
          
        }
    }

    function getNewPrice() public view returns (uint256 newPrice){
        if (IBEP20(uniswapV2PairUsdt).totalSupply() > 0 && balanceOf(uniswapV2PairUsdt) > 10 * 10 ** 18) {
            address[] memory t = new address[](2);

            t[0] = address(this);
            t[1] = usdtAddress;

            uint256[] memory amounts = router.getAmountsOut(1 * (10 ** uint256(_decimals)), t);
            newPrice = amounts[1];
        }
    }


    function updateNodePool(uint256 amout) private {

        if (totalHoldForReward == 0) {
            rewardNodePool.lastReward = rewardNodePool.totalReward;
            rewardNodePool.totalReward = rewardNodePool.totalReward.add(amout);
            return;
        }
        rewardNodePool.totalReward = rewardNodePool.totalReward.add(amout);
        rewardNodePool.accRewardPerShare = rewardNodePool.accRewardPerShare.add(rewardNodePool.totalReward.sub(rewardNodePool.lastReward).mul(1e12).div(totalHoldForReward));
        rewardNodePool.lastReward = rewardNodePool.lastReward.add(amout);
    }

    function assignUsdtRewardFromCallback(uint256 amount) external   {
        if (amount > 0 && address(msg.sender) == address(callback)) {
            updateNodePool(amount);
        }
    }
}