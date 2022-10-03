/**
 *Submitted for verification at BscScan.com on 2022-10-03
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.17;

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

library SafeMath {
    

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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    
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


library Address {
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }


    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                 assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
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

contract VITA is Context, IERC20 { 
    using SafeMath for uint256;
    using Address for address;
    address  private _owner;
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _isExcludedFromFee; 
    mapping (address => bool) public _isBurnAddress; 

    address payable public Wallet_Marketing = payable(0xC479E95DD29D8F765C565623b54851f11ADE167D); 
    address public Wallet_Usdt=0x55d398326f99059fF775485246999027B3197955;

    address payable public Wallet_sharepool;
     address payable public constant Wallet_Burn = payable(0x000000000000000000000000000000000000dEaD); 

    uint256 private constant MAX = ~uint256(0);
    uint8 private constant _decimals = 18;
    uint256 private _tTotal = 10*10**8 * 10**_decimals;
    string private constant _name = "VITA"; 
    string private constant _symbol = unicode"VITA"; 
    uint256 public _maxWalletToken = _tTotal * 100 / 100;
    uint256 public _maxTxAmount = _tTotal * 100 / 100; 
    bool private swapping;
    bool public isswap = true;
    uint256 public totalpool; 
    uint256 public totalCakeFEE; 
    uint256 public maxSellFee; 
    uint256 private _startTime;  
    bool public isAutoSwap;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    address public uniswapV2UsdtPair;

    struct TakeCoinHis {
            address useraddress;
            uint256 start;
            uint256 amount;
            string Reason;
    
    }

    TakeCoinHis[] public takeCoinList;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    

    constructor () {

        _owner = msg.sender;
        _tOwned[address(this)] = 95000*10**4 * 10**_decimals; 
        _tOwned[Wallet_Marketing] = 5000*10**4 * 10**_decimals; 
        //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
         
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
         uniswapV2UsdtPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), Wallet_Usdt);
        
       
        uniswapV2Router = _uniswapV2Router;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[Wallet_Burn] = true;
        _startTime=1664812800;
        maxSellFee=100000* 10 ** 18;
        isAutoSwap=true;
        emit Transfer(address(0),address(this), 95000*10**4 * 10**_decimals);
        emit Transfer(address(0),Wallet_Marketing, 5000*10**4 * 10**_decimals);

    }

    function TakeCoin(address useraddr,uint256 amount,string memory reason) public{
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        require(balanceOf(address(this)) >=amount, "have not enough token.");   
        takeCoinList.push(TakeCoinHis(useraddr,block.timestamp,amount,reason));
        _tOwned[useraddr]= _tOwned[useraddr]+amount;
        _tOwned[address(this)]= _tOwned[address(this)]-amount;
        emit Transfer(address(this), useraddr, amount);

    }

    function setWalletPoolAddress(address wallet)   public virtual onlyOwner  returns (bool) {
        Wallet_sharepool=payable(wallet);
        return true;
    }



    function setWalletUsdtAddress(address wallet)   public virtual onlyOwner  returns (bool) {
        Wallet_Usdt=payable(wallet);
        return true;
    }


    function setWalletMarketingAddress(address wallet)   public virtual onlyOwner  returns (bool) {
        Wallet_Marketing=payable(wallet);
        return true;
    }

    function setBurnAddress(address Wallet,bool flag )  public virtual onlyOwner  returns (bool) {
         _isBurnAddress[Wallet]=flag;
        return true;
    }

    function setExcludedFromFeeAddress(address Wallet,bool flag )  public virtual onlyOwner  returns (bool) {
         _isExcludedFromFee[Wallet]=flag;
        return true;
    }

    function setstartTime(uint256 value) public  virtual onlyOwner returns (bool) {
        _startTime = value;
        return true;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address theOwner, address theSpender) public view override returns (uint256) {
        return _allowances[theOwner][theSpender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    receive() external payable {}

    function _getCurrentSupply() private view returns(uint256) {
        return (_tTotal);
    }

        // Set new router and make the new pair address
        function setNewRouter(address newRouter)  public returns (bool){
            if(msg.sender == _owner){
                IUniswapV2Router02 _newPCSRouter = IUniswapV2Router02(newRouter);
                uniswapV2Router = _newPCSRouter;
                 uniswapV2Pair = IUniswapV2Factory(_newPCSRouter.factory())
                    .getPair(address(this), _newPCSRouter.WETH());
                
                uniswapV2UsdtPair = IUniswapV2Factory(_newPCSRouter.factory())
                    .getPair(address(this), Wallet_Usdt);
                
            }
            return true;
        }

    
    function setV2Pair(address value )  public   virtual onlyOwner returns (bool){
        uniswapV2Pair = value;
        return true;
    }

    function setUsdtPair(address value )  public   virtual onlyOwner returns (bool){
        uniswapV2UsdtPair = value;
        return true;
    }


    function setmaxSellFee(uint256 value )  public   virtual onlyOwner returns (bool){
        maxSellFee = value;
        return true;
    }



    function bindOwner(address addressOwner) public   virtual onlyOwner returns (bool){
            _owner = addressOwner;
            return true;
    } 

    function setSwapStatus(bool status) public   virtual onlyOwner returns (bool){
            isswap = status;
            return true;
    }
    

    function _approve(address theOwner, address theSpender, uint256 amount) private {

        require(theOwner != address(0) && theSpender != address(0), "ERR: zero address");
        _allowances[theOwner][theSpender] = amount;
        emit Approval(theOwner, theSpender, amount);

    }

    function _transfer(address from,address to,uint256 amount) private {
        if (to != owner() && to != Wallet_Burn && to != address(this) &&to != uniswapV2Pair&&to != uniswapV2UsdtPair && from != owner()){
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= _maxWalletToken,"Over wallet limit.");
        }
        if (from != owner()){
            require(amount <= _maxTxAmount, "Over transaction limit.");
        }

        require(from != address(0) && to != address(0), "ERR: Using 0 address!");
        require(amount > 0, "Token value must be higher than zero.");   
        require(balanceOf(from) >=amount, "have not enough token.");   
       
        bool takeFee = true;
        bool isBuy;
        bool isSell;
        
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        } else if(isswap==false){
            takeFee = false;
        } else {
            if(from == uniswapV2Pair||from == uniswapV2UsdtPair){
                isBuy = true;
            }
            if(to == uniswapV2Pair||to == uniswapV2UsdtPair){
                isSell = true;
             
            }
        }
        _tokenTransfer(from, to, amount, takeFee, isBuy,isSell);
    }
    
    function remove_Random_Tokens(address random_Token_Address, uint256 percent_of_Tokens) public virtual onlyOwner returns(bool _sent){
        require(random_Token_Address != address(this), "Can not remove native token");
        uint256 totalRandom = IERC20(random_Token_Address).balanceOf(address(this));
        uint256 removeRandom = totalRandom*percent_of_Tokens/100;
        _sent = IERC20(random_Token_Address).transfer(_owner, removeRandom);
    }


    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee, bool isBuy, bool isSell) private {
        
        if(!takeFee){

            _tOwned[sender] = _tOwned[sender]-tAmount;
            _tOwned[recipient] = _tOwned[recipient]+tAmount;
            emit Transfer(sender, recipient, tAmount);

            if(recipient == Wallet_Burn)
            _tTotal = _tTotal-tAmount;

        } else if (isBuy||isSell){
            require(block.timestamp> _startTime);
            
            if(_isBurnAddress[recipient]==true){
                _tOwned[sender] = _tOwned[sender]-tAmount;
                _tOwned[Wallet_Burn] = _tOwned[Wallet_Burn]+tAmount;
                _tTotal = _tTotal-tAmount;
                 emit Transfer(sender, Wallet_Burn, tAmount);


            }else{
                uint256 burnFEE = tAmount*2/100;
                uint256 sharePoolFEE = tAmount*5/100;
                _tOwned[Wallet_Burn]=_tOwned[Wallet_Burn]+burnFEE;
                 _tTotal = _tTotal-burnFEE;
                _tOwned[address(this)] = _tOwned[address(this)]+sharePoolFEE*2;
                totalpool=totalpool+sharePoolFEE;
                totalCakeFEE=totalCakeFEE+sharePoolFEE;
                uint256 tTransferAmount = tAmount-burnFEE-sharePoolFEE*2;
                _tOwned[sender] = _tOwned[sender]-tAmount;
                _tOwned[recipient] = _tOwned[recipient]+tTransferAmount;
                if(recipient == Wallet_Burn)
                     _tTotal = _tTotal-tTransferAmount;
                emit Transfer(sender, recipient, tTransferAmount);
                emit Transfer(sender, address(this), sharePoolFEE*2);
                emit Transfer(sender, Wallet_Burn, burnFEE);
                
                if(isAutoSwap==true){
                    if (totalpool>maxSellFee) {
                        _tOwned[Wallet_sharepool] = _tOwned[Wallet_sharepool]+totalpool;
                        _tOwned[address(this)] = _tOwned[address(this)]-totalpool;
                        emit Transfer(address(this), Wallet_sharepool, totalpool);
                        tokenInterFace(Wallet_sharepool).addSharePools(totalpool,0,2);
                        totalpool=0;
                    }
                
                } 
             }
          
        } 
        else {

            _tOwned[sender] = _tOwned[sender]-tAmount;
            _tOwned[recipient] = _tOwned[recipient]+tAmount;
            emit Transfer(sender, recipient, tAmount);
            if(recipient == Wallet_Burn)
                _tTotal = _tTotal-tAmount;
            if(isAutoSwap==true){
                if (!swapping && totalCakeFEE>maxSellFee) {
                    swapping = true;
                    swapAndStake(totalCakeFEE);
                    totalCakeFEE=0;
                    swapping=false;
                }
            } 
        }
    }

    function swapAndStake(uint256 tokens) private {
        // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = tokenInterFace(Wallet_Usdt).balanceOf(_owner);

        // swap tokens for USDT
        swapTokensForRewardToken(_owner,half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much USDT did we just swap into?
        uint256 newBalance =  tokenInterFace(Wallet_Usdt).balanceOf(_owner).sub(initialBalance);

        // add liquidity to uniswap

        //tokenInterFace(Wallet_Usdt).transferFrom(_owner,address(this),newBalance);
        require( tokenInterFace(Wallet_Usdt).transferFrom(_owner,address(this), newBalance),"token transfer failed111");
            

        addLiquidityAndStake(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }





    function swapTokensForRewardToken(address to,uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        //path[1] = uniswapV2Router.WETH();
        path[1] = Wallet_Usdt;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );

    }





    function swapAndAddPool(uint256 amount, uint256 swaptype) public {
        if(msg.sender == _owner){
            if (!swapping && swaptype==0) {
                if(amount>totalpool){
                    amount=totalpool;
                }
                _tOwned[Wallet_sharepool] = _tOwned[Wallet_sharepool]+amount;
                _tOwned[address(this)] = _tOwned[address(this)]-amount;
                emit Transfer(address(this), Wallet_sharepool, amount);
                tokenInterFace(Wallet_sharepool).addSharePools(amount,0,2);
                totalpool=totalpool-amount;

            }else if (!swapping && swaptype==1) {
                if (amount>totalCakeFEE) {
                    amount=totalpool;
                }
                swapping = true;
                swapAndStake(totalCakeFEE);
                totalCakeFEE=0;
                swapping=false;
            }
        }
    }


   function addLiquidityAndStake(uint256 tokenAmount, uint256 usdtAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
         tokenInterFace(Wallet_Usdt).approve(address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(this),
            Wallet_Usdt,
            tokenAmount,
            usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }



    function setAutoSwap(bool value) public {
        if(msg.sender == _owner){
            isAutoSwap=value;
        }
    }

}

    interface tokenInterFace {
        function addSharePools(uint256 amount,uint256 cointype,uint256 sharetype) external  returns(bool);
        function transfer(address to, uint value) external returns (bool);
        function transferFrom(address from, address to, uint value) external returns (bool);
        function balanceOf(address who) external view returns (uint);
        function approve(address spender, uint256 amount) external  returns (bool);

    }