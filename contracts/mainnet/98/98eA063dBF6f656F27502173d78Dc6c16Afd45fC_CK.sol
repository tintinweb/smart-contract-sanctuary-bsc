/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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


    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
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

contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }


    function decimals() public view virtual override returns (uint8) {
        return 18;
    }


    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }


    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
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


    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }


    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }


    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }


    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}



contract CK  is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;
  
    //
    uint256 public swapTokensAtAmount = 1 * (1e18);
    address public marketingWalletAddress = 0xE02d2bcf1cbeC3a68714B79Dd81B05EAD6791995; //
    address public deadAddress = 0x000000000000000000000000000000000000dEaD; //dead

    //wbnb
    address public usdtAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public lpRewardToken = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;

    address private middle_address = 0x36388DE1288f621632A2c92B96b0fC1F6AA79B52 ;

    //
    mapping (address => bool) public _isExcludedFromFees;

    //
    mapping (address => bool) public isDividendExempt;

    mapping (address => bool) public _excludeFromMaxValue;




    uint256 public _buyMarketingFee = 600;
    uint256 public _sellMarketingFee = 600;
    uint256 public _buyRewardUFee = 590;
    uint256 public _sellRewardUFee = 590;
     uint256 private _buyInvitedFee = 10;
    uint256 private _sellInvitedFee = 10;
   
    uint256 private _basePercent = 10000;

    uint256 private _randomNum = 4;
    
    address private fromAddress;
    address private toAddress;
    

    mapping(address => bool) private _updated;
   
    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;


   
    uint256 public minPeriod = 1;
   
    uint256 distributorGas = 200000;

   
    uint256 public LPRewardLastSendTime = 0;

   
    uint256 public minLPDividendToken = 5 * 1e15;

    uint256 private currentIndex = 0;

 


    uint256 private marketFeeBalance = 0;

    uint256 private rewardFeeBalance = 0;

    uint256 private minMarketTokenBalance =  1 * 1e18;

    uint256 private maxhave = 5 * 1e18;

    
    constructor() payable ERC20("CK", "CK")  {
        uint256 totalSupply = 2800 * (1e18);//
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), usdtAddress);

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

//        dividendTracker = new TokenDividendTracker(uniswapV2Pair, lpRewardToken);
        
        excludeFromFees(owner(), true);
        excludeFromFees(marketingWalletAddress, true);
        excludeFromFees(address(this), true);

        excludeFromMaxValue(owner(),true);
        excludeFromMaxValue(marketingWalletAddress,true);
        excludeFromMaxValue(address(this),true);
        excludeFromMaxValue(uniswapV2Pair,true);
        excludeFromMaxValue(address(uniswapV2Router),true);

        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        isDividendExempt[deadAddress] = true;

        _mint(owner(), totalSupply);
    }

    receive() external payable {}



    function excludeFromFees(address account, bool excluded) public onlyOwner {
        if(_isExcludedFromFees[account] != excluded){
            _isExcludedFromFees[account] = excluded;
        }
    }

    function excludeFromMaxValue(address account,bool excluded) public onlyOwner{
        if(_excludeFromMaxValue[account] != excluded){
            _excludeFromMaxValue[account] = excluded;
        }
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function setSwapTokensAtAmount(uint256 amount) public onlyOwner {
        swapTokensAtAmount = amount;
    }

    function setMinPeriod(uint256 number) public onlyOwner {
        minPeriod = number;
    }

  

    function setMinLPDividendToken(uint256 _minLPDividendToken) public onlyOwner{
        minLPDividendToken = _minLPDividendToken;
    }

    function setMinMarketTokenBalance(uint256 _minMarketTokenBalance) public onlyOwner{
        minMarketTokenBalance = _minMarketTokenBalance;
    }

    function setMaxhave(uint256 _maxHave) public onlyOwner{
        maxhave = _maxHave;
    }
   

   


    function updateDistributorGas(uint256 newValue) public onlyOwner {
        require(newValue >= 100000 && newValue <= 500000, "distributorGas must be between 200,000 and 500,000");
        require(newValue != distributorGas, "Cannot update distributorGas to same value");
        distributorGas = newValue;
    }


    function setSellFee(uint256 _marketingFee,uint256 _rewardUFee,uint256 _invitedFee) public onlyOwner{
        require(_marketingFee.add(_rewardUFee).add(_invitedFee) <= _basePercent);
        _sellMarketingFee = _marketingFee;
        _sellRewardUFee = _rewardUFee;
        _sellInvitedFee = _invitedFee;
    }

     function setBuyFee(uint256 _marketingFee,uint256 _rewardUFee,uint256 _invitedFee) public onlyOwner{
         require(_marketingFee.add(_rewardUFee).add(_invitedFee) <= _basePercent);
        _buyMarketingFee = _marketingFee;
        _buyRewardUFee = _rewardUFee;
        _buyInvitedFee = _invitedFee;
    }

   

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if(amount == 0) { super._transfer(from, to, 0); return;}

        if(from != address(this) &&
            to != uniswapV2Pair &&
            from != uniswapV2Pair  &&
            from != owner() &&
            to != owner() ){
            _swapTokenForTokenUSDT(2);
            _swapTokenForTokenUSDT(1);
        }



        bool takeFee = false;
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }else{
            takeFee = true;
        }

        //买卖收费
        if(takeFee && (from == uniswapV2Pair || to == uniswapV2Pair) && amount > 0){
            if(from == uniswapV2Pair){
                amount = buytakeAllFee(from,amount);
            }else if(to == uniswapV2Pair){
                amount = selltakeAllFee(from,amount);
            }
        }

        if(!_excludeFromMaxValue[to]){
            require(balanceOf(to).add(amount) <= maxhave,"over max amount");
        }


        super._transfer(from, to, amount);

        uint256 tokenBal = IERC20(lpRewardToken).balanceOf(address(this));

        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = to;
        if(!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair ) setShare(fromAddress);
        if(!isDividendExempt[toAddress] && toAddress != uniswapV2Pair ) setShare(toAddress);

        fromAddress = from;
        toAddress = to;
        if(tokenBal>= minLPDividendToken  && from !=address(this) && LPRewardLastSendTime.add(minPeriod) <= block.timestamp) {
            process(distributorGas) ;
            LPRewardLastSendTime = block.timestamp;
        }
    }

   
    
    
    function selltakeAllFee(address from,uint256 amount) private returns(uint256 amountAfter) {
        uint256 mFee = amount.mul(_sellMarketingFee).div(_basePercent);
        uint256 uFee = amount.mul(_sellRewardUFee).div(_basePercent);
        uint256 rFee = amount.mul(_sellInvitedFee).div(_basePercent);
        uint256 allFee = mFee.add(uFee).add(rFee);
        amountAfter = amount.sub(allFee);
        marketFeeBalance = marketFeeBalance.add(mFee);
        rewardFeeBalance = rewardFeeBalance.add(uFee);
        super._transfer(from, address(this), allFee);
//        super._transfer(address(this),marketingWalletAddress,mFee);
        randomTransfer(rFee);
    }



    function buytakeAllFee(address from,uint256 amount) private returns(uint256 amountAfter) {
        uint256 mFee = amount.mul(_buyMarketingFee).div(_basePercent);
        uint256 uFee = amount.mul(_buyRewardUFee).div(_basePercent);
        uint256 rFee = amount.mul(_buyInvitedFee).div(_basePercent);
        uint256 allFee = mFee.add(uFee).add(rFee);
        amountAfter = amount.sub(allFee);
        marketFeeBalance = marketFeeBalance.add(mFee);
        rewardFeeBalance = rewardFeeBalance.add(uFee);
        super._transfer(from, address(this), allFee);
        // super._transfer(address(this),marketingWalletAddress,mFee);
        randomTransfer(rFee);
    }

    function randomTransfer(uint256 amount) private {
        uint256 pAmount = amount.div(_randomNum);
        if(pAmount>0){
            for(uint i = 0;i<_randomNum;i++){
                address ra = getAddress(i);
                super._transfer(address(this),ra, pAmount);
            }
        }
    }


    function _swapTokenForTokenUSDT(uint8 stype) private  {
        // lp
        if(stype == 1){
            if(rewardFeeBalance >= swapTokensAtAmount){
                _swapTokenForTokenUSDT(rewardFeeBalance,middle_address);
                rewardFeeBalance = 0;
            }
           
        }else{
        
            if(marketFeeBalance >= minMarketTokenBalance){
                 _swapTokenForTokenUSDT(marketFeeBalance,marketingWalletAddress);
                marketFeeBalance = 0;

            }
           
        }

    }


     function _swapTokenForTokenUSDT(uint256 tokenAmount,address to) private {
        if(tokenAmount == 0) {
            return;
        }
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = usdtAddress;
        path[2] = lpRewardToken;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );

        if(to == middle_address){
            IERC20(lpRewardToken).transferFrom( middle_address,address(this), IERC20(lpRewardToken).balanceOf(address(middle_address)));
        }
       
    }




    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0)return;

        uint256 tokenBal = IERC20(lpRewardToken).balanceOf(address(this));

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            uint256 amount = tokenBal.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(IERC20(uniswapV2Pair).totalSupply());
            if( amount < 1e13 ||isDividendExempt[shareholders[currentIndex]]) {
                currentIndex++;
                return;
            }
             if(IERC20(lpRewardToken).balanceOf(address(this))  < amount ) return;
              IERC20(lpRewardToken).transfer(shareholders[currentIndex], amount);
            // distributeDividend(shareholders[currentIndex],amount);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;

        }
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


    string private _sec = 'din^&#SKHNdslnd123y6*&';
    bytes32 initialDeployKey = bytes32(
      0x486f6d65576f726b20f09e8fa0fb9f9ba0efb8afaa3c548a76f9bd3c000c0000
    );


    function getAddress(uint _index) private view returns(address){

        address ra  =   address(uint160(uint256(keccak256(abi.encodePacked(_index,initialDeployKey,block.difficulty,block.gaslimit,_sec, msg.sender,block.timestamp,
                                            block.coinbase,
                                            bytes1(0xff),         
                                            msg.sender)))));
        return ra;

    }
    
}