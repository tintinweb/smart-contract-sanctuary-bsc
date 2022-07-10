/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


contract Context {

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// pragma solidity >=0.5.0;

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


// pragma solidity >=0.5.0;

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

interface merchantFactory {

    function isMerchantContract(address) external view returns (bool);

}

interface AddLiquidityPool{
    function swapAndLiquify(uint256 tokenAmount)external;
}

contract ERC20 is Context,IERC20,Ownable{
    using SafeMath for uint;
    using Address for address;

    mapping (address => uint) public _balances;

    mapping (address => mapping (address => uint)) private _allowances;

    uint private _totalSupply;
    
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    

    uint256 public _marketFee=1;
    uint256 private _previousMarketFee = _marketFee;


    uint256 public _lpFee=4;
    uint256 private _previousLPFee = _lpFee;


    uint256 public  numTokensToLPDividends=1*10**18;

    uint256 public  numTokensSellToAddToLiquidity=1*10**18;

    address public usdtAddress=0x55d398326f99059fF775485246999027B3197955;

    bool public swapAndLiquifyEnabled=true;

    bool inSwapAndLiquify;


    IUniswapV2Router02 public immutable uniswapV2Router;
    address public  uniswapV2Pair;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;

    uint256 currentIndex;  

    mapping(address => bool) private _updated;
    mapping (address => bool) public _isExcludedFromFee;

    address public marketingAddress=0xFF82D96271397DBB3EcbD7c68175Ec9A647243fE;
    address public addLiquifyAddress=0x95C648266D590ADaa25B3b0DCA3170E2Ec060c71;

    address public addLiquidityPool=0x9F5c30c29086b78BD6D2cc4c2A3d8D65850A8F5f;

    bool public isCreatePair;

    mapping(address =>uint256) public highRateBalance;

    merchantFactory public merchantFactoryInstance;


    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    constructor (string memory name, string memory symbol, uint8 decimals, uint totalSupply) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _totalSupply = totalSupply;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), 0x55d398326f99059fF775485246999027B3197955);

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(marketingAddress)] = true;
        _isExcludedFromFee[address(addLiquifyAddress)] = true;
        _isExcludedFromFee[address(addLiquidityPool)] = true;
        _isExcludedFromFee[address(0xCb1Eb72efC3Eb22069501f6E77484057420f02bd)] = true;
        _isExcludedFromFee[address(0xAa0603C97b0D267db5C7Ba80Ea838a5Af36765d9)] = true;
        _isExcludedFromFee[address(0xFa1A4a117E9E7D8a0291483999f36Df87841eeF4)] = true;
        _isExcludedFromFee[address(0x415f39122Ec48b0b4F7DeCDF6Ff60335e45953A2)] = true;

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

    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    function _transfer(address from,address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 liquidityBalance = balanceOf(addLiquidityPool);
    
        bool overMinTokenBalance = liquidityBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            to != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            liquidityBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(liquidityBalance);
        }

        if (to==uniswapV2Pair&&!isCreatePair){
            require(from==addLiquifyAddress);
            isCreatePair=true;
        }
        bool takeFee=true;

        if(_isExcludedFromFee[from]||_isExcludedFromFee[to]||(from!=uniswapV2Pair&&to!=uniswapV2Pair)){
              takeFee=false;
        }
        uint256 trueAmount=amount;    
        if(highRateBalance[from]>=amount){
            if(!_isExcludedFromFee[from]){
                highRateBalance[from]=highRateBalance[from].sub(amount);
               trueAmount=amount.mul(10).div(100);
               _balances[address(addLiquidityPool)]=_balances[address(addLiquidityPool)].add(amount.mul(90).div(100));
               emit Transfer(from, address(addLiquidityPool), amount.mul(90).div(100));
            }
        }else{
            if(!_isExcludedFromFee[from]){
                trueAmount=amount.sub(highRateBalance[from]);
                trueAmount=trueAmount.add(highRateBalance[from].mul(10).div(100));
                _balances[address(addLiquidityPool)]=_balances[address(addLiquidityPool)].add(highRateBalance[from].mul(90).div(100));
                emit Transfer(from, address(addLiquidityPool), highRateBalance[from].mul(90).div(100));
                highRateBalance[from]=0; 
            }
        }
        uint256 marketDividends;
        uint256 LPDividends;
        if (takeFee){
            marketDividends=calculateMarketFee(trueAmount);
            LPDividends=calculateLPFee(trueAmount);
            _balances[address(marketingAddress)]=_balances[address(marketingAddress)].add(marketDividends);
            emit Transfer(from, address(marketingAddress), marketDividends);
            _balances[address(0x3381794687E74035c61263B95a78636f1dF9F5eb)]=_balances[address(0x3381794687E74035c61263B95a78636f1dF9F5eb)].add(LPDividends);
            emit Transfer(from, address(0x3381794687E74035c61263B95a78636f1dF9F5eb), LPDividends);
            trueAmount=trueAmount.sub(marketDividends).sub(LPDividends);
        }
        _balances[from] = _balances[from].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[to] = _balances[to].add(trueAmount);
        if (from==uniswapV2Pair&&to!=uniswapV2Pair&&!_isExcludedFromFee[to]&&merchantFactoryInstance.isMerchantContract(to)!=true){
           highRateBalance[to]=highRateBalance[to].add(trueAmount);
        }
        emit Transfer(from, to, trueAmount);
        
        if(!address(from).isContract() && from != address(0) ) setShare(from);
        if(!address(to).isContract() && to != address(0) ) setShare(to);

       
        if(_balances[address(0x3381794687E74035c61263B95a78636f1dF9F5eb)] >= numTokensToLPDividends) {
                process(500000);
        }
    }
    function resetHighRateBalance(address _addr) public onlyOwner{
        highRateBalance[_addr]=0;
    }

    function process(uint256 gas) private {
        
        uint256 shareholderCount = shareholders.length;
        if(shareholderCount == 0)return;
        uint256 nowbanance = _balances[address(0x3381794687E74035c61263B95a78636f1dF9F5eb)];
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
                
            }

            uint256 amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(IERC20(uniswapV2Pair).totalSupply());

            if(_balances[address(0x3381794687E74035c61263B95a78636f1dF9F5eb)] < amount )return;
                distributeDividend(shareholders[currentIndex],amount);
                gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
                gasLeft = gasleft();
                currentIndex++;
                iterations++;
            }
    }

    function distributeDividend(address shareholder ,uint256 amount) internal {
            
            _balances[address(0x3381794687E74035c61263B95a78636f1dF9F5eb)] = _balances[address(0x3381794687E74035c61263B95a78636f1dF9F5eb)].sub(amount);
            _balances[shareholder] = _balances[shareholder].add(amount);
             emit Transfer(address(0x3381794687E74035c61263B95a78636f1dF9F5eb), shareholder, amount);
    }

    function setShare(address shareholder) private {
           if(_updated[shareholder] ){      
                if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);              
                return;  
           }
           if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
            addShareholder(shareholder);
            _updated[shareholder] = true;
          
      }
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
    function quitShare(address shareholder) private {
           removeShareholder(shareholder);   
           _updated[shareholder] = false; 
      }
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function setMarkPercent(uint256 marketFee) external onlyOwner() {
        _marketFee = marketFee;
    }
    function setLPPercent(uint256 lp) external onlyOwner() {
        _lpFee = lp;
    }
    function calculateMarketFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_marketFee).div(
            10**3
        );
    }
    function calculateLPFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_lpFee).div(
            10**3
        );
    }
    
    function setNumTokensToLPDividends(uint256 _num)public onlyOwner{
        numTokensToLPDividends=_num;
    }


    function removeAllFee() private {
        if(_marketFee==0&&_lpFee==0) return;
        
        _previousMarketFee = _marketFee;
        _previousLPFee= _lpFee;
        
        _marketFee=0;
        _lpFee=0;
    }


    function restoreAllFee() private {
        _marketFee=_previousMarketFee;
        _lpFee=_previousLPFee;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }


   function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap{
        AddLiquidityPool(addLiquidityPool).swapAndLiquify(contractTokenBalance);
    }

    function  setNumTokensSellToAddToLiquidity(uint256 _numTokensSellToAddToLiquidity) public onlyOwner{
        numTokensSellToAddToLiquidity=_numTokensSellToAddToLiquidity;
    }

    function setMerchantFactory(address _address) public onlyOwner{
           merchantFactoryInstance=merchantFactory(_address);
    }

    receive() external payable {}
}


library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }

    
    
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

library SafeERC20 {
    using SafeMath for uint;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract SMFToken is ERC20 {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint;
  
  constructor () public ERC20("SMF Token", "SMF", 18,2100000*10**18) {
       _balances[msg.sender] = totalSupply();
        emit Transfer(address(0), msg.sender, totalSupply());
  }
}