/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

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
        return c;
    }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface InterfaceLP {
    function sync() external;
}

interface IDEXRouter {
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

contract KodiAPY is IBEP20, Auth {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping (address => uint256) _rBalance;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) private isFeeExempt;
    mapping (address => bool) private _isAllowedToTradeWhenDisabled;

    uint256 public _liquidityFee;
    uint256 public _marketingFee;
    uint256 public _additionalFeeOnSell;
    uint256 private _totalFee;

    address public marketingWallet;

    IDEXRouter public router;
    address public pair;
    InterfaceLP public pairContract;

    bool public swapEnabled = true;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    uint256 private initialSupply;
    uint256 public _totalSupply;
    uint256 private rSupply;
    uint256 public swapThreshold;

    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant MAX_SUPPLY = ~uint128(0);
    
    uint256 public rebase_count = 0;
    uint256 public rate;
    uint256 public constant rebaseTimeInterval = 30 minutes;

    bool public isTradingEnabled;

    // Auto Rebase settings
    bool public autoRebase;
    uint256 public rebaseRate;
    uint256 private _lastRebasedTime;

    event AllowedWhenTradingDisabledChange(address indexed account, bool isExcluded);
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event SwapAndLiquify(uint256 bnbIntoLiquidity,uint256 tokensIntoLiqudity);
    event WalletChange(string indexed indentifier, address indexed newWallet, address indexed oldWallet);

    function _rebase_percentage(uint256 _percentage_base1000000000) private {
        rebase(0,uint256(_totalSupply.div(1000000000).mul(_percentage_base1000000000)));
    }

    function rebase(uint256 epoch, uint256 supplyDelta) private {
        if (inSwap) return;

        rebase_count++;
        if(epoch == 0){
            epoch = rebase_count;
        }

        require(!inSwap, "Try again");

        if (supplyDelta > 0) { 
            _totalSupply = _totalSupply.add(uint256(supplyDelta));
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        rate = rSupply.div(_totalSupply);
        pairContract.sync();

        emit LogRebase(epoch, _totalSupply);
    }

    constructor (
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply_,
        uint256 rebaseRate_,
        uint256 liquidityFee_,
        uint256 marketingFee_,
        uint256 additionalFeeOnSell_,
        address marketingWallet_,
        address router_
    )   Auth(msg.sender) {
        require(liquidityFee_ >= 0);
        require(marketingFee_ >= 0);
        require(liquidityFee_.add(marketingFee_).add(additionalFeeOnSell_) <= 25,
                "Total fees cannot be more than 25%");

        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;

        router = IDEXRouter(router_);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = uint256(-1);
        
        initialSupply = initialSupply_ * (10**decimals_);
        rSupply = MAX_UINT256 - (MAX_UINT256 % initialSupply);
        swapThreshold = rSupply / 1000;
        _totalSupply = initialSupply;
        rate = rSupply.div(_totalSupply);
        
        pairContract = InterfaceLP(pair);

        isFeeExempt[owner] = true;
        _isAllowedToTradeWhenDisabled[owner] = true;

        isTradingEnabled = false;
        autoRebase = false;
        rebaseRate = rebaseRate_;
        _lastRebasedTime = block.timestamp;

        _marketingFee = marketingFee_;
        _liquidityFee = liquidityFee_;
        _totalFee = marketingFee_ + liquidityFee_;
        _additionalFeeOnSell = additionalFeeOnSell_;
        marketingWallet = marketingWallet_;

        _rBalance[owner] = rSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    receive() external payable { }

    
    
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external view override returns (uint8) { return _decimals; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function name() external view override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }

    function balanceOf(address account) public view override returns (uint256) {
        return _rBalance[account].div(rate);
    }
    
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function approveMax(address spender) external returns (bool) {
        return approve(spender, uint256(-1));
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != uint256(-1)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function activateTrading() public onlyOwner {
		isTradingEnabled = true;
        autoRebase = true;
	}

    function allowTradingWhenDisabled(address account, bool allowed) public onlyOwner {
		_isAllowedToTradeWhenDisabled[account] = allowed;
		emit AllowedWhenTradingDisabledChange(account, allowed);
	}

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(!_isAllowedToTradeWhenDisabled[sender] && !_isAllowedToTradeWhenDisabled[recipient]) {
			require(isTradingEnabled, "Trading is currently disabled.");
        }
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        uint256 rAmount = amount.mul(rate);

        bool isSelltoLp = recipient == pair;

        if(shouldSwapBack()){ swapBack(); }

        if(shouldRebase()){ 
            _rebase_percentage(rebaseRate); 
            _lastRebasedTime = block.timestamp;
        }

        //Exchange tokens
        _rBalance[sender] = _rBalance[sender].sub(rAmount, "Insufficient Balance");

        uint256 amountReceived = (!shouldTakeFee(sender) || !shouldTakeFee(recipient)) ? rAmount : takeFee(sender, rAmount, isSelltoLp);
        _rBalance[recipient] = _rBalance[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived.div(rate));
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        uint256 rAmount = amount.mul(rate);
        _rBalance[sender] = _rBalance[sender].sub(rAmount, "Insufficient Balance");
        _rBalance[recipient] = _rBalance[recipient].add(rAmount);
        emit Transfer(sender, recipient, rAmount.div(rate));
        return true;
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(address sender, uint256 rAmount, bool isSellToLp) internal returns (uint256) {
        if(isSellToLp){
            _totalFee += _additionalFeeOnSell;
        } 

        uint256 feeAmount = rAmount.div(100).mul(_totalFee);

        if(isSellToLp){
            _totalFee -= _additionalFeeOnSell;
        } 

        _rBalance[address(this)] = _rBalance[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount.div(rate));

        return rAmount.sub(feeAmount);
    }

    function shouldRebase() internal view returns (bool) {
        return
            autoRebase &&
            (_totalSupply < MAX_SUPPLY) &&
            msg.sender != pair  &&
            !inSwap &&
            block.timestamp >= (_lastRebasedTime + rebaseTimeInterval);
    }

    function autoRebaseEnabled(bool enabled) public onlyOwner {
        autoRebase = enabled;
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _rBalance[address(this)] >= swapThreshold;
    }

    function claimStuckTokens(address token) external onlyOwner {
        require(token != address(this), "Owner cannot claim native tokens");
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IBEP20 BEP20token = IBEP20(token);
        uint256 balance = BEP20token.balanceOf(address(this));
        BEP20token.transfer(msg.sender, balance);
    }
    

    function swapBack() internal swapping {
        uint256 contractBalance = balanceOf(address(this));
		uint256 initialBNBBalance = address(this).balance;

        uint256 amountToLiquify = contractBalance * _liquidityFee / _totalFee / 2;
        uint256 amountToSwap = contractBalance.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 bnbBalanceAfterSwap = address(this).balance.sub(initialBNBBalance);

        uint256 totalBNBFee = _totalFee.sub(_liquidityFee.div(2));
        
        uint256 amountBNBLiquidity = bnbBalanceAfterSwap.mul(_liquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBMarketing = bnbBalanceAfterSwap.mul(_marketingFee).div(totalBNBFee);
        
        if (_marketingFee > 0) {
            payable(marketingWallet).transfer(amountBNBMarketing);
        }

        if(_liquidityFee > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                DEAD,
                block.timestamp
            );
            emit SwapAndLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    function _swapTokensForBNB(uint256 tokenAmount) private {
		address[] memory path = new address[](2);
		path[0] = address(this);
		path[1] = router.WETH();

		router.swapExactTokensForETHSupportingFeeOnTransferTokens(
			tokenAmount,
			0, // accept any amount of ETH
			path,
			address(this),
			block.timestamp
		);
	}

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
		router.addLiquidityETH{value: ethAmount}(
			address(this),
			tokenAmount,
			0, // slippage is unavoidable
			0, // slippage is unavoidable
			DEAD,
			block.timestamp
		);
	}    
    
    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setFees(uint256 liquidityFee, uint256 marketingFee, uint256 additionalFeeOnSell) external authorized {
        _liquidityFee = liquidityFee;
        _marketingFee = marketingFee;
        _additionalFeeOnSell = additionalFeeOnSell;
        _totalFee = liquidityFee.add(marketingFee);
        require(_totalFee.add(additionalFeeOnSell) <= 25 , "Fees cannot be more than 25%");
    }

    function setWallets(address newMarketingWallet) public onlyOwner {
		if(marketingWallet != newMarketingWallet) {
			require(newMarketingWallet != address(0), "The marketingWallet cannot be 0");
			emit WalletChange('marketingWallet', newMarketingWallet, marketingWallet);
			marketingWallet = newMarketingWallet;
		}
    }
    function setSwapBackSettings(bool _enabled, uint256 _percentage_base100000) external authorized {
        swapEnabled = _enabled;
        swapThreshold = rSupply.div(100000).mul(_percentage_base100000);
    }

    function manualSync() external {
        InterfaceLP(pair).sync();
    }
    
    function setLP(address _address) external onlyOwner {
        pairContract = InterfaceLP(_address);
        isFeeExempt[_address];
    }

    function checkSwapThreshold() external view returns (uint256) {
        return swapThreshold.div(rate);
    }
        
    function getCirculatingSupply() public view returns (uint256) {
        return (rSupply.sub(_rBalance[DEAD]).sub(_rBalance[ZERO])).div(rate);
    }

}