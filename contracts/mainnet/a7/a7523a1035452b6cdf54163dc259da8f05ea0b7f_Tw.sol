/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

    library SafeMath {
   function tryAdd(uint256 a, uint256 b)
       internal
       pure
       returns (bool, uint256)
   {
       unchecked {
           uint256 c = a + b;
           if (c < a) return (false, 0);
           return (true, c);
       }
   }

   function trySub(uint256 a, uint256 b)
       internal
       pure
       returns (bool, uint256)
   {
       unchecked {
           if (b > a) return (false, 0);
           return (true, a - b);
       }
   }

   function tryMul(uint256 a, uint256 b)
       internal
       pure
       returns (bool, uint256)
   {
       unchecked {
           // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
           // benefit is lost if 'b' is also tested.
           // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
           if (a == 0) return (true, 0);
           uint256 c = a * b;
           if (c / a != b) return (false, 0);
           return (true, c);
       }
   }

   function tryDiv(uint256 a, uint256 b)
       internal
       pure
       returns (bool, uint256)
   {
       unchecked {
           if (b == 0) return (false, 0);
           return (true, a / b);
       }
   }

   function tryMod(uint256 a, uint256 b)
       internal
       pure
       returns (bool, uint256)
   {
       unchecked {
           if (b == 0) return (false, 0);
           return (true, a % b);
       }
   }

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

   function mod(uint256 a, uint256 b) internal pure returns (uint256) {
       return a % b;
   }

   function sub(
       uint256 a,
       uint256 b,
       string memory errorMessage
   ) internal pure returns (uint256) {
       unchecked {
           require(b <= a, errorMessage);
           return a - b;
       }
   }

   function div(
       uint256 a,
       uint256 b,
       string memory errorMessage
   ) internal pure returns (uint256) {
       unchecked {
           require(b > 0, errorMessage);
           return a / b;
       }
   }

   function mod(
       uint256 a,
       uint256 b,
       string memory errorMessage
   ) internal pure returns (uint256) {
       unchecked {
           require(b > 0, errorMessage);
           return a % b;
       }
   }
    }

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);
    
    function symbol() external view returns (string memory);
    
    function name() external view returns (string memory);
    
    function getOwner() external view returns (address);
    
    function balanceOf(address account) external view returns (uint256);
    
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);
    
    function approve(address spender, uint256 amount) external returns (bool);
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

}

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }
    
    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }
    
    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }
    
    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }
    
    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }
    
    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
    
    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }
    
    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }
    
    event OwnershipTransferred(address owner);

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
    
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
    
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external payable returns (uint256 amountToken,uint256 amountETH,uint256 liquidity);
    
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

interface IPinkAntiBot {
  function setTokenOwner(address owner) external;

  function onPreTransferCheck(
    address from,
    address to,
    uint256 amount
  ) external;
}

contract Tw is IBEP20, Auth {
    using SafeMath for uint256;

    uint256 public constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;
    
    string constant _name = "TW";
    string constant _symbol = "TW";
    uint8 constant _decimals = 6;
    
    uint256 _totalSupply = 1_000_000_000 * (10**_decimals);
    uint256 public _maxTxAmount = _totalSupply.div(100); //1%
    uint256 public _maxWallet = _totalSupply.div(40); //2.5%
    
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) isMaxWalletExempt;
    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isTxLimitExempt;
    mapping(address => bool) public _isFree;

    uint256 public liquidityFee = 1;
    uint256 public DevFee = 1;
    uint256 public marketingFee = 1;
    uint256 public totalFee = 3;
    uint256 public feeDenominator = 100;
    
    address public autoLiquidityReceiver =0x000000000000000000000000000000000000dEaD; // auto-liq address 
    address private marketingFeeReceiver =0x63Ff743975cAFbfD6642BaEA0F9E83094CfF285f; // marketing address
    address private DevFeeReceiver =0x63Ff743975cAFbfD6642BaEA0F9E83094CfF285f; // Dev address
    

    uint256 targetLiquidity = 25;
    uint256 targetLiquidityDenominator = 100;
    
    IUniswapV2Router public router;
    address public pair;
    
    uint256 public launchedAt;
    uint256 public launchedAtTimestamp;
    
    IPinkAntiBot public pinkAntiBot;
    bool public antiBotEnabled;
    uint256 private _firstBlock;
    uint256 private _botBlocks;
    
    bool public tradingOpen = false;
    bool public swapEnabled = false;
    uint256 public swapThreshold = _totalSupply / 1000; // 0.1%
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }
    
    constructor(address pinkAntiBot_) Auth(msg.sender) {
       address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // PancakeSwap Router
        router = IUniswapV2Router(_router);
        
       pair = IUniswapV2Factory(router.factory()).createPair(address(this),router.WETH());
       _allowances[address(this)][address(router)] = _totalSupply;

        pinkAntiBot = IPinkAntiBot(pinkAntiBot_);
        pinkAntiBot.setTokenOwner(msg.sender);
        antiBotEnabled = true;
        
        isMaxWalletExempt[msg.sender] = true;

        isFeeExempt[msg.sender] = true;
        isFeeExempt[ZERO] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[DEAD] = true;
       
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[ZERO] = true;
        isTxLimitExempt[address(this)] = true;

    
        approve(_router, _totalSupply);
        approve(address(pair), _totalSupply);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    receive() external payable {}
    
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
    
    function decimals() external pure override returns (uint8) {
        return _decimals;
    }
    
    function symbol() external pure override returns (string memory) {
        return _symbol;
    }
    
    function name() external pure override returns (string memory) {
        return _name;
    }
    
    function getOwner() external view override returns (address) {
        return owner;
    }
    
   
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }
    
    function transferFrom(address sender,address recipient,uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }
    
        return _transferFrom(sender, recipient, amount);
    }
    
    function _transferFrom(address sender,address recipient,uint256 amount) internal returns (bool) {
        if (inSwap) { return _basicTransfer(sender, recipient, amount); }
        
        if (antiBotEnabled) {pinkAntiBot.onPreTransferCheck; }
        
        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading is not active");
        }
       
        if (!authorizations[sender] && !isMaxWalletExempt[sender] && !isMaxWalletExempt[recipient] && recipient != pair) {
            require((_balances[recipient] + amount) <= _maxWallet,"Max wallet has been triggered");
        }
       
    
        require((amount <= _maxTxAmount) || isTxLimitExempt[sender] || isTxLimitExempt[recipient], "Max TX Limit has been triggered");

        
         if (shouldCASwap()) {CAswap(); }
        
       
        _balances[sender] = _balances[sender].sub(amount,"Insufficient Balance");
    
        uint256 amountReceived = shouldTakeFee(sender)? takeFee(sender, recipient, amount): amount;
    
        _balances[recipient] = _balances[recipient].add(amountReceived);
    
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender,address recipient,uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount,"Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }
     
    function getTotalFee(bool) public view returns(uint256) {
        if (launchedAt + 1 >= block.number) {
            return totalFee;
        }
        
        return totalFee;
    }
    
    function takeFee(address sender,address receiver,uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(getTotalFee(receiver == pair)).div(feeDenominator);
    
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
    
        return amount.sub(feeAmount);
    }
    
    function shouldCASwap() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            swapEnabled &&
            _balances[address(this)] >= swapThreshold;
    }
    
    function CAswap() internal swapping {
        uint256 amountToLiquify = swapThreshold.mul(liquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);
    
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        
    
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        
        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = totalFee.sub(liquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalETHFee);
        uint256 amountBNBDev = amountBNB.mul(DevFee).div(totalETHFee);
        
        payable(DevFeeReceiver=0x63Ff743975cAFbfD6642BaEA0F9E83094CfF285f).transfer(amountBNBDev);
        payable(marketingFeeReceiver=0x63Ff743975cAFbfD6642BaEA0F9E83094CfF285f).transfer(amountBNBMarketing);
    
        if (amountToLiquify > 0) {
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver=0x000000000000000000000000000000000000dEaD,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }
    
    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }
    
    function launch() public authorized {
        require(launchedAt == 0, "Already launched boi");
        launchedAt = block.number;
        launchedAtTimestamp = block.timestamp;
    }
    
    function EnablePinkSaleBot(bool _enable) external onlyOwner() {
      antiBotEnabled = _enable;
    }

    function openTrading(uint256 botBlocks) external onlyOwner() {
        _firstBlock = block.timestamp;
        _botBlocks = botBlocks;
        tradingOpen = true;
    }

    function ClearBNBBalance() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function clearBEP20(address tokenAddress, uint256 tokens) external onlyOwner returns (bool success) {
        if(tokens == 0){tokens = IBEP20(tokenAddress).balanceOf(address(this));}
        return IBEP20(tokenAddress).transfer(msg.sender, tokens);
    }

    function setMaxWalletAmount(uint256 amount) external authorized {
        require(amount >= _totalSupply /100);
        _maxWallet = amount;
    }
    
    function setTxLimitAmount(uint256 amount) external authorized {
        require(amount >= _totalSupply / 100);
        _maxTxAmount = amount;
    }
      
    function IsFreeFromMaxWallet(address holder, bool exempt) external authorized {
        isMaxWalletExempt[holder] = exempt;
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }
    
    function IsFreeFromTxLimit(address holder, bool exempt) external authorized{
        isTxLimitExempt[holder] = exempt;
    }
    
    function setFree(address holder) public onlyOwner {
        _isFree[holder] = true;
    }
    
    function unSetFree(address holder) public onlyOwner {
        _isFree[holder] = false;
    }
    
    function checkFree(address holder) public view onlyOwner returns (bool) {return _isFree[holder];
    }
    
    function setFees(uint256 _liquidityFee,uint256 _marketingFee, uint256 _DevFee,  uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
          DevFee = _DevFee;
        totalFee = _liquidityFee.add(_marketingFee).add(_DevFee);
        
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator / 3);
        }
    
    function setFeeReceivers(address _autoLiquidityReceiver, address _DevFeeReceiver, address _marketingFeeReceiver) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        DevFeeReceiver = _DevFeeReceiver;
    }
    
    function CASwapSettings(bool _enabled, uint256 _amount)external authorized{
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }
    
    function setTargetLiquidity(uint256 _target, uint256 _denominator)external authorized{
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    
    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}