// SPDX-License-Identifier: MIT

/*

 .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------.   
| .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |  
| |  _______     | || |      __      | || |   ______     | || |   ______     | || |     _____    | || |  _________   | |  
| | |_   __ \    | || |     /  \     | || |  |_   _ \    | || |  |_   _ \    | || |    |_   _|   | || | |  _   _  |  | |  
| |   | |__) |   | || |    / /\ \    | || |    | |_) |   | || |    | |_) |   | || |      | |     | || | |_/ | | \_|  | |  
| |   |  __ /    | || |   / ____ \   | || |    |  __'.   | || |    |  __'.   | || |      | |     | || |     | |      | |  
| |  _| |  \ \_  | || | _/ /    \ \_ | || |   _| |__) |  | || |   _| |__) |  | || |     _| |_    | || |    _| |_     | |  
| | |____| |___| | || ||____|  |____|| || |  |_______/   | || |  |_______/   | || |    |_____|   | || |   |_____|    | |  
| |              | || |              | || |              | || |              | || |              | || |              | |  
| '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |  
 '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'   
          
                    .----------------.  .----------------.  .----------------.  .----------------.                                           
                    | .--------------. || .--------------. || .--------------. || .--------------. |                                          
                    | |    ______    | || |     _____    | || |  _______     | || |   _____      | |                                          
                    | |  .' ___  |   | || |    |_   _|   | || | |_   __ \    | || |  |_   _|     | |                                          
                    | | / .'   \_|   | || |      | |     | || |   | |__) |   | || |    | |       | |                                          
                    | | | |    ____  | || |      | |     | || |   |  __ /    | || |    | |   _   | |                                          
                    | | \ `.___]  _| | || |     _| |_    | || |  _| |  \ \_  | || |   _| |__/ |  | |                                          
                    | |  `._____.'   | || |    |_____|   | || | |____| |___| | || |  |________|  | |                                          
                    | |              | || |              | || |              | || |              | |                                          
                    | '--------------' || '--------------' || '--------------' || '--------------' |                                          
                    '----------------'  '----------------'  '----------------'  '----------------'                                           
                
                    .----------------.  .----------------.  .----------------.  .----------------.                                           
                    | .--------------. || .--------------. || .--------------. || .--------------. |                                          
                    | |    _____     | || |     ____     | || |    _____     | || |    ______    | |                                          
                    | |   / ___ `.   | || |   .'    '.   | || |   / ___ `.   | || |   / ____ `.  | |                                          
                    | |  |_/___) |   | || |  |  .--.  |  | || |  |_/___) |   | || |   `'  __) |  | |                                          
                    | |   .'____.'   | || |  | |    | |  | || |   .'____.'   | || |   _  |__ '.  | |                                          
                    | |  / /____     | || |  |  `--'  |  | || |  / /____     | || |  | \____) |  | |                                          
                    | |  |_______|   | || |   '.____.'   | || |  |_______|   | || |   \______.'  | |                                          
                    | |              | || |              | || |              | || |              | |                                          
                    | '--------------' || '--------------' || '--------------' || '--------------' |                                          
                    '----------------'  '----------------'  '----------------'  '----------------' 

*/


pragma solidity 0.8.17;

import 'IERC20.sol';
import 'IUniswapV2Pair.sol';
import 'IUniswapV2Router01.sol';
import 'Address.sol';
import 'IUniswapV2Factory.sol';
import 'IUniswapV2Router02.sol';
import 'SafeMath.sol';
import 'Context.sol';
import 'Ownable.sol';

interface LoterryInterface {
     function getWinnerAmount(address who) external view returns(bool, uint);
     function deleteWinner(address who) external;
}

contract RabbitGirl2023 is Context, IERC20, Ownable {
    
    address lotteryContractAddress;

    using SafeMath for uint256;
    using Address for address;
    
    string private _name = "RabbitGirl";
    string private _symbol = "RG";
    uint8 private _decimals = 9;

    address marketingAddress;
    address devAddress;

    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
   
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isWalletLimit;

    uint256 public _LiquidityFee = 4;
    uint256 public _DevFee = 4;
    uint256 public _MarketingFee = 2;

    uint public _totalTax = 10;
    uint public maxAmountRate = 20;
    uint256 public maxTotalSupply =  1e15 * 10**_decimals;
    uint256 private _totalSupply =  5e14 * 10**_decimals;
    uint256 public maxWalletOwnAmount = _totalSupply.div(maxAmountRate);

    uint256 private minimumTokensBeforeSwap = 5e11 * 10**_decimals; 

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    bool public checkWalletLimit = true;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event Win(
        address from,
        uint256 amount
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    modifier onlyWinner{
        (bool status, ) = LoterryInterface(lotteryContractAddress).getWinnerAmount(msg.sender);
        require(status, "Err");
        _;
    }

    modifier checkWallet(address to, uint amount){
        if(checkWalletLimit && !isWalletLimit[to])
            require(_balances[to] + amount <= maxWalletOwnAmount,"Err");
            _;
    }
    
    constructor (address _marketingAddress, address _devAdress) {
        marketingAddress = _marketingAddress;
        devAddress = _devAdress;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = maxTotalSupply;

        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
        
        isWalletLimit[owner()] = true;
        isWalletLimit[uniswapV2Pair] = true;
        isWalletLimit[address(this)] = true;
        
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

    function justWinMint() public onlyWinner {
        (,uint amount) = LoterryInterface(lotteryContractAddress).getWinnerAmount(msg.sender);
        require(maxTotalSupply >=_totalSupply.add(amount), "Err");
        LoterryInterface(lotteryContractAddress).deleteWinner(msg.sender);
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        emit Transfer(address(0), msg.sender, amount);
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return minimumTokensBeforeSwap;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function setIsExcludedFromFee(address account, bool newValue) public onlyOwner {
        isExcludedFromFee[account] = newValue;
    }    

    function setAllTax(uint256 newLiquidityFee, uint256 newMarketingFee, uint256 newDevFee) external onlyOwner() {
        require(_totalTax >= newLiquidityFee.add(newMarketingFee).add(newDevFee), "Max Tax Err");
        _LiquidityFee = newLiquidityFee;
        _MarketingFee = newMarketingFee;
        _DevFee = newDevFee;

        _totalTax = newLiquidityFee.add(newMarketingFee).add(newDevFee);
    }

    function changeWalletLimitStatus() external onlyOwner {
       checkWalletLimit = !checkWalletLimit;
    }

    function setNumTokensBeforeSwap(uint256 newLimit) external onlyOwner() {
        minimumTokensBeforeSwap = newLimit;
    }

    function setMarketingWallet(address newAddress) external onlyOwner() {
        marketingAddress = newAddress;
    }

    function setDevWallet(address newDevAddress) external onlyOwner() {
        devAddress = newDevAddress;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
    function changeRouterVersion(address newRouterAddress) public onlyOwner returns(address newPairAddress) {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(newRouterAddress); 

        newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(address(this), _uniswapV2Router.WETH());

        if(newPairAddress == address(0))
        {
            newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());
        }

        uniswapV2Pair = newPairAddress;
        uniswapV2Router = _uniswapV2Router; 

    }

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

    function _transfer(address sender, address recipient, uint256 amount) private checkWallet(recipient, amount) returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
        uint lastAmount = calculateAmount(sender, recipient, amount);
        
        if(inSwapAndLiquify)
        { 
            return _superTransfer(sender, recipient, amount); 
        }
        else
        {
            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;
            
            if (overMinimumTokenBalance && !inSwapAndLiquify &&  sender != uniswapV2Pair && swapAndLiquifyEnabled) 
            {
                swapAndLiquify(contractTokenBalance);    
            }

            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            _balances[recipient] = _balances[recipient].add(lastAmount);

            emit Transfer(sender, recipient, lastAmount);
            return true;
        }
    }

    function calculateAmount(address from, address to, uint amount) internal returns(uint){
        if(isExcludedFromFee[from] || isExcludedFromFee[to])
            return (amount);
        return takeFee(from, amount);
    }

    function _superTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
 
        uint256 _UnitTokenAmount = contractTokenBalance.div(_totalTax);
        uint _LiquidityAmount = _UnitTokenAmount.mul(_LiquidityFee).div(2);
        uint _DevAmount = _UnitTokenAmount.mul(_DevFee);

        uint _MarketingAmount = _UnitTokenAmount.mul(_MarketingFee);
        uint256 _LiquidityOtherHalf = _UnitTokenAmount.mul(_LiquidityFee).div(2);
        uint256 totalSwapAmount = _LiquidityAmount.add(_DevAmount).add(_MarketingAmount);
        // swap tokens for ETH
        swapTokensForEth(totalSwapAmount); 
        
        uint256 newUintBalance = (address(this).balance).div(_totalTax);
        uint256 liquidityBalance = newUintBalance.mul(_LiquidityFee);
        uint256 devBalance = newUintBalance.mul(_DevFee);
        uint256 marketingBalance = newUintBalance.mul(_MarketingFee);
        
        
        addLiquidity(_LiquidityOtherHalf, liquidityBalance);

        payable(marketingAddress).transfer(marketingBalance);
        payable(devAddress).transfer(devBalance);

        emit SwapAndLiquify(_LiquidityAmount, liquidityBalance, _LiquidityOtherHalf);
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
            address(this),
            block.timestamp
        );
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

    function setLotteryContractAddress(address _new) public onlyOwner{
        lotteryContractAddress = _new;
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(_totalTax).div(100);
        
        if(feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount);
    }

    function changeMaxAmountRate(uint newRate) public onlyOwner{
        maxAmountRate = newRate;
    }

    function withdrawEarnings() public onlyOwner {
		payable(msg.sender).transfer(address(this).balance);
	}
}