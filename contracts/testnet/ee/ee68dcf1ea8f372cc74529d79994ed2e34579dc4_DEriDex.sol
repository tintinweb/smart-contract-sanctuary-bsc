/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

// File: tokennnn.sol



pragma solidity ^0.8.4;

interface Erc20Interface{
    function totalSupply () external view returns(uint);
    function balanceOf (address tokenOwner) external view returns (uint balance);
    function transfer(address to, uint tokens) external returns (bool success);

    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
 }


 abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
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


contract DEriDex is Context, Erc20Interface{
    
    string public name = "Deri";
    string public symbol = "DRI";
    string public decimal = "4";

    uint public override totalSupply;
    address public owner;
     mapping(address=>uint) public balances;
     mapping(address=>mapping(address=>uint)) allowed;

     mapping (address => uint256) private _tOwned;
     mapping (address => mapping (address => uint256)) private _allowances;
     mapping (address => bool) public _isExcludedFromFee; 

    address payable public Marketing = payable(0xe686dDc3d2820472C5A88088b17594b2A4F84B6f); 
    address payable public devFeeReceiver = payable(0xe686dDc3d2820472C5A88088b17594b2A4F84B6f);
    address payable public constant Wallet_Burn = payable(0x000000000000000000000000000000000000dEaD);
    address payable public Team = payable(0xe686dDc3d2820472C5A88088b17594b2A4F84B6f);
    address payable public AutoLP = payable(msg.sender);
    
    uint8 private txCount = 0;
    uint8 private swapTrigger = 10; 

    uint256 public Buy_Tax = 3;
    uint256 public Sell_Tax = 3;
   
    uint256 public _Marketing = 3;
    uint256 public _Team = 4;
    uint256 public _Dev = 2;
    uint256 public _Burn = 0;
    uint256 public _AutoLP = 1; 
    uint256 public totalFee = _Marketing + _Team + _Dev + _AutoLP + _Burn;
    uint256 public feeDenominator  = 100;

    uint256 public _maxWalletToken = 900;
    uint256 private _previousMaxWalletToken = _maxWalletToken;

    uint256 public _maxTxAmount = 1000; 
    uint256 private _previousMaxTxAmount = _maxTxAmount;


    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
    event SwapAndLiquifyEnabledUpdated(bool true_or_false);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
        
    );

    modifier onlyOwner(){
         require(msg.sender==owner);
         _;
    }
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

      constructor(){
         totalSupply= 10 * 10**6 * 10**4;

         owner = msg.sender;
         balances[owner]=totalSupply;
         


         IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); 
        // //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // Testnet
        
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        // // _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[Marketing] = true; 
        
        //  emit Transfer(address(0), owner(), totalSupply);
         
         
     }



      function balanceOf(address tokenOwner) public view override returns(uint balance){
         return balances[tokenOwner];
     }
       

       // to transfer tokens and check if sender has exact amount of tokens available
     function transfer (address to, uint tokens) public  override returns(bool success){
         require(balances[msg.sender]>=tokens);
         balances[to]+=tokens; //balances[to]=balances[to]+tokens;
         balances[msg.sender]-=tokens;
         emit Transfer(msg.sender,to,tokens);
         return true;
     }

     function approve(address spender, uint tokens) public override returns(bool success){
         require(balances[msg.sender]>=tokens);
         require(tokens>0);
         allowed[msg.sender][spender]=tokens;
         emit Approval(msg.sender,spender,tokens);
         return true;

     }

     function allowance(address tokenOwner, address spender) public view override returns( uint noOfTokens){
         return allowed[tokenOwner][spender];
     }

     function transferFrom(address from, address to, uint tokens) public override returns(bool success){
        require(allowed[from][to]>=tokens);
        require(balances[from]>=tokens);
        balances[from]-=tokens;
        balances[to]+=tokens;
        return true;
     }

     // function to change ownership

     function ChangeOwnership(address _owner) public onlyOwner {
         owner = _owner;
     }




   



    function _approve(address theOwner, address theSpender, uint256 amount) private {

        require(theOwner != address(0) && theSpender != address(0), " Cant send to zero address");
        _allowances[theOwner][theSpender] = amount;
        emit Approval(theOwner, theSpender, amount);

    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

        // if (to != owner() &&
            
        //     to != address(this) &&
        //     to != uniswapV2Pair &&
        //     from != owner()){
        //     uint256 heldTokens = balanceOf(to);
        //     require((heldTokens + amount) <= _maxWalletToken,"Over wallet limit.");}

        // if (from != owner())
        //     require(amount <= _maxTxAmount, "Over transaction limit.");


        require(from != address(0) && to != address(0), "ERR: Using 0 address!");
        require(amount > 0, "Token  must be higher than zero.");   

        if(
            txCount >= swapTrigger && 
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled 
            )
        {  
            
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance > _maxTxAmount) {contractTokenBalance = _maxTxAmount;}
            txCount = 0;
            swapAndLiquify(contractTokenBalance);
        }
        
        bool takeFee = true;
        bool isBuy;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        } else {
         
            if(from == uniswapV2Pair){
                isBuy = true;
            }

            txCount++;

        }

        _tokenTransfer(from, to, amount, takeFee, isBuy);

    }
    
    function sendToWallet(address payable wallet, uint256 amount) private {
            wallet.transfer(amount);

        }


    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {

            uint256 tokens_to_Burn = contractTokenBalance * _Burn / 100;
            totalSupply = totalSupply - tokens_to_Burn;
            // _tOwned[Wallet_Burn] = _tOwned[Wallet_Burn] + tokens_to_Burn;
            _tOwned[address(this)] = _tOwned[address(this)] - tokens_to_Burn; 

            uint256 tokens_to_M = contractTokenBalance * _Marketing / 100;
            uint256 tokens_to_D = contractTokenBalance * _Dev / 100;
            uint256 tokens_to_LP_Half = contractTokenBalance * _AutoLP / 200;

            uint256 balanceBeforeSwap = address(this).balance;
            swapTokensForBNB(tokens_to_LP_Half + tokens_to_M + tokens_to_D);
            uint256 BNB_Total = address(this).balance - balanceBeforeSwap;

            uint256 split_M = _Marketing * 100 / (_AutoLP + _Marketing + _Dev);
            uint256 BNB_M = BNB_Total * split_M / 100;

            uint256 split_D = _Dev * 100 / (_AutoLP + _Marketing + _Dev);
            uint256 BNB_D = BNB_Total * split_D / 100;


            addLiquidity(tokens_to_LP_Half, (BNB_Total - BNB_M - BNB_D));
            emit SwapAndLiquify(tokens_to_LP_Half, (BNB_Total - BNB_M - BNB_D), tokens_to_LP_Half);

            sendToWallet(Marketing, BNB_M);

            BNB_Total = address(this).balance;
            sendToWallet(devFeeReceiver, BNB_Total);

            }

    function swapTokensForBNB(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }


    function addLiquidity(uint256 tokenAmount, uint256 BNBAmount) private {

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: BNBAmount}(
            address(this),
            tokenAmount,
            0, 
            0,
            Wallet_Burn, 
             
            block.timestamp
        );
    } 

    // function remove_Random_Tokens(address random_Token_Address, uint256 percent_of_Tokens) public returns(bool _sent){
    //     require(random_Token_Address != address(this), "Can not remove native token");
    //     uint256 totalRandom = IERC20(random_Token_Address).balanceOf(address(this));
    //     uint256 removeRandom = totalRandom*percent_of_Tokens/100;
    //     _sent = IERC20(random_Token_Address).transfer(Wallet_Dev, removeRandom);

    // }


    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee, bool isBuy) private {
        
        
        if(!takeFee){

            _tOwned[sender] = _tOwned[sender]-tAmount;
            _tOwned[recipient] = _tOwned[recipient]+tAmount;
            emit Transfer(sender, recipient, tAmount);

            if(recipient == Wallet_Burn)
            totalSupply = totalSupply-tAmount;

            } else if (isBuy){

            uint256 buyFEE = tAmount*Buy_Tax/100;
            uint256 tTransferAmount = tAmount-buyFEE;

            _tOwned[sender] = _tOwned[sender]-tAmount;
            _tOwned[recipient] = _tOwned[recipient]+tTransferAmount;
            _tOwned[address(this)] = _tOwned[address(this)]+buyFEE;   
            emit Transfer(sender, recipient, tTransferAmount);

            if(recipient == Wallet_Burn)
            totalSupply = totalSupply-tTransferAmount;
            
            } else {

            uint256 sellFEE = tAmount*Sell_Tax/100;
            uint256 tTransferAmount = tAmount-sellFEE;

            _tOwned[sender] = _tOwned[sender]-tAmount;
            _tOwned[recipient] = _tOwned[recipient]+tTransferAmount;
            _tOwned[address(this)] = _tOwned[address(this)]+sellFEE;   
            emit Transfer(sender, recipient, tTransferAmount);

            if(recipient == Wallet_Burn)
            totalSupply = totalSupply-tTransferAmount;


            }

    }

     function setMaxWalletToken(uint256 amount) external onlyOwner() {
        _maxWalletToken = amount;
    }

    function setMaxTxPercent_base1000(uint256 maxTXPercentage_base1000) external onlyOwner() {
        _maxTxAmount = (totalSupply * maxTXPercentage_base1000 ) / 1000;
    }

    function setMaxTxAmount(uint256 amount) external onlyOwner {
        _maxTxAmount = amount;
    }


    function setFees(uint256 _liquidityFee,  uint256 _marketingFee, uint256 _TeamFee, uint256 _devFee, uint256 _burnfee,  uint256 _feeDenominator) external onlyOwner {
        _AutoLP = _liquidityFee;
        _Marketing = _marketingFee;
        _Dev = _devFee;
        _Team = _TeamFee;
        _Burn = _burnfee;
        totalFee = _liquidityFee + _marketingFee + _devFee + _TeamFee + _burnfee;
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator/2, "Fees cannot be more than 49%");
    }

     function setFeeReceiver(address payable _marketingWallet, address payable _lpFeeWallet, address payable _TeamFeeWallet) external onlyOwner{
         Marketing = _marketingWallet;
         AutoLP = _lpFeeWallet;
         Team = _TeamFeeWallet;


     }


}