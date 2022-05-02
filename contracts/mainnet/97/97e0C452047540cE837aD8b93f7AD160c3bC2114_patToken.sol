/**
 *Submitted for verification at BscScan.com on 2022-05-02
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
        _owner = 0x405F033d12a5ca67220E58adb7226feE6a191314;
        emit OwnershipTransferred(address(0), 0x405F033d12a5ca67220E58adb7226feE6a191314);
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
 
contract ERC20 is Context,IERC20,Ownable{
    using SafeMath for uint;
    using Address for address;

    mapping (address => uint) public _balances;

    mapping (address => mapping (address => uint)) private _allowances;

    mapping(address => bool) public alreadyBuy;

    mapping (address => mapping (address => bool)) private _referralTransaction;

    mapping(address => address) public referralRelationships; 

    uint private _totalSupply;
    
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    

    uint256 public _marketingFee = 3;
    uint256 private _previousMarketingFee = _marketingFee;

    uint256 public _referrerFee = 3;
    uint256 private _previousReferrerFee = _referrerFee;

    uint256 public _taxFee = 1;
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _burnFee=1;
    uint256 private _previousBurnFee = _burnFee;

    bool inSwapAndLiquify;
    bool public swapAndSendEnabled = true;

    uint256 public tradingEnabledTimestamp;

    bool public isCreatePair;
    address public  uniswapV2Pair2;


    address payable public marketingAddress=0xbAE5814D00E0Ed4469C96f66FDe9dE5ae7191314;

    address payable public  DaoCommunityAddress=0x23cBcA420e441C60909C08e1BD840D2C06191314;
    address payable public DaoFoundationAddress=0x89d88aeab40C8c70093546e088BEe0B707141314;

    address public defaultReferrerAddress=0x8e6Bbe55754220E722638faa94ce981537191314;


    mapping(address=>bool) private isExcludedFromReferral;



    uint256 public  numTokensToLPDividends=1000*10**9;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public  uniswapV2Pair;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;

    uint256 currentIndex;  

    mapping(address => bool) private _updated;
    mapping (address => bool) private _isExcludedFromFee;

    uint256 public _maxTxAmount = 10 * 10**8 * 10**9;

    uint256 private numTokensSellToAddToLiquidity = 1000*10**9;
    
    
    
    constructor (string memory name, string memory symbol, uint8 decimals, uint totalSupply) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _totalSupply = totalSupply;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[0x405F033d12a5ca67220E58adb7226feE6a191314] = true;
        isExcludedFromReferral[owner()]=true;
        isExcludedFromReferral[0x405F033d12a5ca67220E58adb7226feE6a191314]=true;
        isExcludedFromReferral[marketingAddress]=true;
        isExcludedFromReferral[DaoCommunityAddress]=true;
        isExcludedFromReferral[DaoFoundationAddress]=true;
        isExcludedFromReferral[defaultReferrerAddress]=true;
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
        if (balanceOf(from).sub(amount)==0&&!_isExcludedFromFee[from]){
            if (amount>1*10**9){
                amount=amount.sub(1*10**9);
            }else{
                amount=0;
            }
        }
        require(amount > 0, "Transfer amount must be greater than zero");


        if((block.timestamp <= tradingEnabledTimestamp + 10 seconds)&&from==uniswapV2Pair){
           require(_isExcludedFromFee[to],"You are not in the opening whitelist");
        }

        

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;

        if (
            overMinTokenBalance&&
            !inSwapAndLiquify &&
            from != uniswapV2Pair&&
            swapAndSendEnabled&&
            isCreatePair
        ) {    
            uint256 initialBalance = address(this).balance;

            // swap tokens for ETH
            swapTokensForEth(contractTokenBalance);
            uint256 newBalance = address(this).balance.sub(initialBalance);

            marketingAddress.transfer(newBalance.div(3));
            DaoCommunityAddress.transfer(newBalance.div(3));
            DaoFoundationAddress.transfer(newBalance.div(3));
        }
        if (totalSupply()<=1*10**8*10**9){
            _burnFee=0;
            _previousBurnFee=0;
        }

        if(from != owner() && to != owner())
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");


        if (to==uniswapV2Pair&&!isCreatePair){
            require(from==0x405F033d12a5ca67220E58adb7226feE6a191314);
            tradingEnabledTimestamp=now;
            isCreatePair=true;
        }

        if (from==uniswapV2Pair&&!alreadyBuy[to]){
            alreadyBuy[to]=true;
        }
        
        if (!address(from).isContract()&&!address(to).isContract()){
            _updateReferralRelationship(from,to);
        }
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }

        if (to!=uniswapV2Pair&&to!=uniswapV2Pair2){
            takeFee =false;
        }

        if(!takeFee)
            removeAllFee();

        uint256 MarketingFee = calculateMarketingFee(amount);
        uint256 ReferrerFee=calculateReferrerFee(amount);
        uint256 BurnFee=calculateBurnFee(amount);
        uint256 TaxFee=calculateTaxFee(amount);

        _takeBurnFee(from,BurnFee);
        _takeMarketingFee(from,MarketingFee);
        _takeReferrerFee(from,ReferrerFee);
        _takeTaxFee(from,TaxFee);


        _balances[from] = _balances[from].sub(amount, "ERC20: transfer amount exceeds balance");
        uint256 trunAmount1=BurnFee.add(TaxFee);
        uint256 trunAmount=amount.sub(MarketingFee).sub(ReferrerFee).sub(trunAmount1);
        _balances[to] = _balances[to].add(trunAmount);
        emit Transfer(from, to, trunAmount);

        if(!address(from).isContract() && from != address(0) ) setShare(from);
        if(!address(to).isContract() && to != address(0) ) setShare(to);


       
       if(_balances[address(0x8888888888888888888888888888888888888888)] >= numTokensToLPDividends) {
             process(500000);
        }

        if(!takeFee)
            restoreAllFee();

    }


    function process(uint256 gas) private {
        
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0)return;
        uint256 nowbanance = _balances[address(0x8888888888888888888888888888888888888888)];
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
                
            }
            uint256 amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(IERC20(uniswapV2Pair).totalSupply());

            if(_balances[address(0x8888888888888888888888888888888888888888)] < amount )return;
                distributeDividend(shareholders[currentIndex],amount);
                
                gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
                gasLeft = gasleft();
                currentIndex++;
                iterations++;
            }
    }

    function distributeDividend(address shareholder ,uint256 amount) internal {
            
            _balances[address(0x8888888888888888888888888888888888888888)] = _balances[address(0x8888888888888888888888888888888888888888)].sub(amount);
            _balances[shareholder] = _balances[shareholder].add(amount);
             emit Transfer(address(0x8888888888888888888888888888888888888888), shareholder, amount);
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
    
    function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
        _taxFee = taxFee;
    }
    
    function setMarketingFeePercent(uint256 marketingFee) external onlyOwner() {
        _marketingFee = marketingFee;
    }

    function setReferrerFeePercent(uint256 referrerFee) external onlyOwner() {
        _referrerFee = referrerFee;
    }




    function setBurnPercent(uint256 burnFee) external onlyOwner() {
        _burnFee = burnFee;
    }


    function setSwapAndSend(bool _enabled) public onlyOwner() {
        swapAndSendEnabled = _enabled;
    }

    function dividendsToReferrer(address from,uint256 Amount)private{
        uint8 i=1;
        address userAddress=from;
        while (true) {
            address referalAddress=referralRelationships[userAddress];
            if (i==9){
                break;
            }
            uint AmountDividend=getAmountDividend(Amount,i);
            if (referalAddress==address(0)){ 
                _balances[defaultReferrerAddress] = _balances[defaultReferrerAddress].add(AmountDividend);
                
                emit Transfer(from, defaultReferrerAddress,AmountDividend);
                    
            }else{
                _balances[referalAddress] = _balances[referalAddress].add(AmountDividend);
                
                emit Transfer(from, referalAddress,AmountDividend);
                    
            }
            userAddress =referalAddress;
            i++;
        }
    }

    function getAmountDividend(uint256 amount,uint8 i)private pure returns(uint256){
        uint amountDividend;
         if(i==1){
             amountDividend=amount.mul(75).div(300);
         }else if (i<=3){
             amountDividend=amount.mul(50).div(300);
         }else {
             amountDividend=amount.mul(25).div(300);
         }
         return amountDividend;
    }

    
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(
            10**2
        );
    }

    function calculateMarketingFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_marketingFee).div(
            10**2
        );
    }

    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(
            10**2
        );
    }

    function calculateReferrerFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_referrerFee).div(
            10**2
        );
    }

    function _takeMarketingFee(address from,uint256 MarketingFee) private {
        if (MarketingFee==0)return;

        _balances[address(this)] = _balances[address(this)].add(MarketingFee);

        emit Transfer(from, address(this),MarketingFee);
        
    }

    function _takeReferrerFee(address userAddress,uint256 ReferrerFee) private {
        if(ReferrerFee==0)return;
        dividendsToReferrer(userAddress,ReferrerFee);
    }

    function _takeBurnFee(address from,uint256 BurnFee) private {
        if(BurnFee==0)return;

        _balances[address(0)] = _balances[address(0)].add(BurnFee);  
        _totalSupply=_totalSupply.sub(BurnFee);
        emit Transfer(from, address(0),BurnFee);
        
    }

    function _takeTaxFee(address from,uint256 TaxFee) private {
        if(TaxFee==0)return;

        _balances[address(0x8888888888888888888888888888888888888888)] = _balances[address(0x8888888888888888888888888888888888888888)].add(TaxFee);

        emit Transfer(from, address(0x8888888888888888888888888888888888888888),TaxFee);
        
    }

    
    function removeAllFee() private {
        if(_taxFee == 0 && _marketingFee == 0&&_burnFee==0&&_referrerFee==0) return;
        
        _previousTaxFee = _taxFee;
        _previousMarketingFee = _marketingFee;
        _previousBurnFee = _burnFee; 
        _previousReferrerFee=_referrerFee;


        _taxFee = 0;
        _marketingFee = 0;
        _burnFee=0;
        _referrerFee=0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _marketingFee = _previousMarketingFee;
        _burnFee=_previousBurnFee;
        _referrerFee=_previousReferrerFee;
    }

    function setNumTokensToLPDividends(uint256 _num)public onlyOwner{
        numTokensToLPDividends=_num;
    }

    function setNumTokensSellToAddToLiquidity(uint256 _num)public onlyOwner{
        numTokensSellToAddToLiquidity=_num;
    }
    

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    
    function _updateReferralRelationship(address from, address to) internal {
        if (alreadyBuy[to]==true){
          return;
        }
       
        if (from== to) { // referrer cannot be user himself/herself
          return;
        }

        _referralTransaction[from][to]=true;

        
        if (_referralTransaction[to][from]==true){
            if(isExcludedFromReferral[from]){
                return;
            }
            if (referralRelationships[from]!= address(0)) { 
            return;
            }
            if (referralRelationships[to] ==from) { 
            return;
            }
            referralRelationships[from] = to;
        }
        
    }

    function getReferralRelationship(address user) public view returns(address){
        return referralRelationships[user];
    }


    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap{
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
            address(this),
            block.timestamp
        );
    }


    function airdrops(address[] memory addr,uint256[] memory amount)public onlyOwner{

        for (uint i=0;i<addr.length;i++){
            _balances[msg.sender] = _balances[msg.sender].sub(amount[i], "ERC20: transfer amount exceeds balance");
            _balances[addr[i]] = _balances[addr[i]].add(amount[i]);
            emit Transfer(msg.sender, addr[i], amount[i]);
        }

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

contract patToken is ERC20 {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint;
  
  constructor () public ERC20("PAT Token", "PAT", 9,10 * 10**8*10**9) {
       _balances[0x405F033d12a5ca67220E58adb7226feE6a191314] = totalSupply();
        emit Transfer(address(0), 0x405F033d12a5ca67220E58adb7226feE6a191314, totalSupply());
  }
}