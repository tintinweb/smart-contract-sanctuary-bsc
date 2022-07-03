/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
 
contract Efatah33Lock is IERC20 {

    using SafeMath for uint256; 
 
    IPancakeSwapPair public pairContract;
    mapping(address => bool) _isFeeExempt;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }
    
    string private _name = "EFATAH33";
    string private _symbol =  "EFALOCK";
    uint8 private _decimals = 8; 

    uint256 private constant MAX_SUPPLY = 7777700000000; // 77,777 * 10**8; 
    uint256 public _totalSupply = MAX_SUPPLY;
    uint256 private _gonsPerFragment = 1; 
 
    uint256 public feeDenominator = 1000;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public marketingReceiver = 0x167395322efA5A9938BA84aC1aA092dE86b7087e; 
    address public liquidityReceiver = 0x7B797C2a37d70C36c2925708961052F0cE59bC08;
    address public projectReceiver = 0x2355205C9aE00672fF3243C91c44dA128324Df80; 
    address public epifReceiver = 0xD4Cd573eC16D21e3790f23D3ed399ED4b6057F84; 
    address public devReceiver = 0x73d4a3972f305F2F8b498aD29bd433eBcadd0CC2; 
    address public teamReceiver = 0x1bc4DDB70Ea30e90F633822fE569d0A4B24B64F5;  
     
    uint256 public liquidityFee = 1;
    uint256 public devFee = 2;
    uint256 public teamFee = 1;
    uint256 public epifFee = 6;

    uint256 public buyMarketingFee = 3; 
    uint256 public buyProjectFee = 1;  
    uint256 public buyTotalFee =
        buyMarketingFee.add(liquidityFee).add(buyProjectFee).add(devFee).add(teamFee).add(epifFee);

    uint256 public sellMarketingFee = 4; 
    uint256 public sellProjectFee = 2;  
    uint256 public sellTotalFee =
        sellMarketingFee.add(liquidityFee).add(sellProjectFee).add(devFee).add(teamFee).add(epifFee);
 
    uint256 public maxDailyWalletTransferPercent = 100;// 100%
    uint256 public maxTransferTimeSecs = 86400; //24hrs 
    bool public isDirectTransfer = true;
    
    struct user {  uint256 txnTimeSecs; uint256 txnAmount; }
    mapping(address => user) public userDailyTxns;
    
    //DividendDistributor distributor; 
    uint256 distributorGas = 500000; 
    bool public swapEnabled = true;
    IPancakeSwapRouter public router;
    
    address public pair;
    bool inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    bool public _autoRebase;
    bool public _autoAddLiquidity;
    uint256 public _initRebaseStartTime;
    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;

    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;
    mapping(address => bool) public isDividendExempt;

    //Shareholder section 
    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }
    IERC20 BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    //address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => Share) public shares;
    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public currentIndex;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;
    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10 ** 18);



    address private _owner;
    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    event eventSellFees(uint256 percent_rate, uint256 fee_amount, uint256 amount); 
    event eventBuyFees(uint256 percent_rate, uint256 fee_amount, uint256 amount); 
     
    constructor(address ownerWallet) {
        _owner = ownerWallet; 
        _allowedFragments[address(this)][address(router)] = 1; //uint256(-1);
        
        //distributor = new DividendDistributor(_owner);
        //epifReceiver = address(distributor);

        isDividendExempt[_owner] = true; 
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        _gonBalances[_owner] = MAX_SUPPLY; 
        _initRebaseStartTime = block.timestamp;
        _lastRebasedTime = block.timestamp;
        _autoRebase = false;
        _autoAddLiquidity = true;
        _isFeeExempt[_owner] = true;
        _isFeeExempt[address(this)] = true;

        emit Transfer(address(0x0), _owner, _totalSupply);
    }

    function setSwapRouter(address routerAddress) external onlyOwner {
         //testnet
        //router = IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); 
        //mainnet
        // 0x10ED43C718714eb63d5aA57B78B54704E256024E
        router = IPancakeSwapRouter(routerAddress); 
        pair = IPancakeSwapFactory(router.factory()).createPair(router.WETH(), address(this)); 
        pairContract = IPancakeSwapPair(pair);  
        isDividendExempt[pair] = true;   
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    } 

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        //emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
   
    function balanceOf(address account) public view override returns (uint256) {
        return _gonBalances[account].div(_gonsPerFragment);
    }

    function transfer(address to, uint256 value) external override validRecipient(to) returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external override validRecipient(to) returns (bool) {
        if (_allowedFragments[from][msg.sender] != 1 /*uint256(-1)*/) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender].sub(value, "Insufficient Allowance");
        }
        _transferFrom(from, to, value);
        return true;
    }

    function _basicTransfer(address from, address to, uint256 amount) internal returns (bool) {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);
        return true;
    }

    function _transferFrom(address sender, address recipient,  uint256 amount) internal returns (bool) {
        require(amount > 0, "Transfer amount must be greater than zero");
      
        require(!blacklist[sender] && !blacklist[recipient], "in_blacklist");

        if(isDirectTransfer != true) {
            if (shouldAddLiquidity()) {
                addLiquidity();
            }
            if (shouldSwapBack()) {
                swapBack();
            }
        }

        //-----------------
        if (_isFeeExempt[sender]) {  
            //use buy rate, reduce recipient by buyrate  

            uint256 buyfee_amount = buyTotalFee > 0 ? amount.mul(buyTotalFee).div(feeDenominator) : 0;              
            require(buyfee_amount < amount, "Fees cannot exceed Txn. Amount");
            uint256 amount_less_fees = amount.sub(buyfee_amount);  
             
            _gonBalances[sender] = _gonBalances[sender].sub(amount); 
            _gonBalances[recipient] = _gonBalances[recipient].add(amount_less_fees);

           //share the fees to the corresponding addresses
            if(buyfee_amount > 0){
                if(buyMarketingFee > 0) { 
                    _gonBalances[marketingReceiver] = _gonBalances[marketingReceiver].add(amount.mul(buyMarketingFee).div(feeDenominator)); 
                }
                if(liquidityFee > 0) { 
                    _gonBalances[liquidityReceiver] = _gonBalances[liquidityReceiver].add(amount.mul(liquidityFee).div(feeDenominator)); 
                }
                if(buyProjectFee > 0) { 
                    _gonBalances[projectReceiver] = _gonBalances[projectReceiver].add(amount.mul(buyProjectFee).div(feeDenominator)); 
                }
                if(devFee > 0) { 
                    _gonBalances[devReceiver] = _gonBalances[devReceiver].add(amount.mul(devFee).div(feeDenominator)); 
                }  
                if(teamFee > 0) { 
                    _gonBalances[teamReceiver] = _gonBalances[teamReceiver].add(amount.mul(teamFee).div(feeDenominator)); 
                }
                if(epifFee > 0) { 
                    _gonBalances[epifReceiver] = _gonBalances[epifReceiver].add(amount.mul(epifFee).div(feeDenominator)); 
                }  
            }
 
            emit Transfer(sender, recipient, amount);               
            return true; 
        }

          //These transactions involves selling fees  
        uint256 max_amount_transfer_allowed = 0;
        uint256 account_balance = _gonBalances[sender]; 

        if (block.timestamp > (userDailyTxns[sender].txnTimeSecs.add(maxTransferTimeSecs))) {
            //it means last transaction is more than 24 hours
            //1. check if the amount is within the range of max txn cap
            max_amount_transfer_allowed = maxDailyWalletTransferPercent >= 100? account_balance : account_balance.mul(maxDailyWalletTransferPercent).div(100);

            require(amount <= max_amount_transfer_allowed, "Amount exceeded allowed range");
                      
            userDailyTxns[sender].txnTimeSecs = block.timestamp;
            userDailyTxns[sender].txnAmount = amount;

            _transfer(sender, recipient, amount);            
            return true;
        } 
  
        //it means user has done one or more transaction within 24hours              
        account_balance =  userDailyTxns[sender].txnAmount.add(account_balance);
        max_amount_transfer_allowed = maxDailyWalletTransferPercent >= 100? account_balance : account_balance.mul(maxDailyWalletTransferPercent).div(100);  

        require(amount <= max_amount_transfer_allowed, "Amount exceeded allowed range for one day");   

        //userDailyTxns[sender].txnTimeSecs = block.timestamp; still in the 24hrs timeframe
        userDailyTxns[sender].txnAmount = userDailyTxns[sender].txnAmount.add(amount);

        _transfer(sender, recipient, amount);
        return true; 
    }


    function _transfer(address sender, address recipient, uint256 amount) private { 
        //tax_fee and txn_fee 
        uint256 sellfee_amount = sellTotalFee > 0? amount.mul(sellTotalFee).div(feeDenominator) : 0; 
        require(sellfee_amount <= amount, "Fees cannot exceed Txn. Amount"); 
        uint256 amount_less_fees = amount.sub(sellfee_amount);
        
        _gonBalances[sender] = _gonBalances[sender].sub(amount); 
        _gonBalances[recipient] = _gonBalances[recipient].add(amount_less_fees);

        //share the fees to the corresponding addresses  
        if(sellfee_amount > 0) { 
            if(sellMarketingFee > 0) { 
                _gonBalances[marketingReceiver] = _gonBalances[marketingReceiver].add(amount.mul(sellMarketingFee).div(feeDenominator)); 
            }
            if(liquidityFee > 0) { 
                _gonBalances[liquidityReceiver] = _gonBalances[liquidityReceiver].add(amount.mul(liquidityFee).div(feeDenominator)); 
            }
            if(sellProjectFee > 0) { 
                _gonBalances[projectReceiver] = _gonBalances[projectReceiver].add(amount.mul(sellProjectFee).div(feeDenominator)); 
            }
            if(epifFee > 0) { 
                _gonBalances[epifReceiver] = _gonBalances[epifReceiver].add(amount.mul(epifFee).div(feeDenominator)); 
            }
            if(devFee > 0) { 
                _gonBalances[devReceiver] = _gonBalances[devReceiver].add(amount.mul(devFee).div(feeDenominator)); 
            }
            if(teamFee > 0) { 
                _gonBalances[teamReceiver] = _gonBalances[teamReceiver].add(amount.mul(teamFee).div(feeDenominator)); 
            }
 
            emit eventSellFees(sellTotalFee, sellfee_amount, amount);  
        }  

         if(isDirectTransfer != true){
            if(!isDividendExempt[sender]){ setShare(sender, balanceOf(sender)); }
            if(!isDividendExempt[recipient]){ setShare(recipient, balanceOf(recipient));  }
            process(distributorGas);
         }
        
        emit Transfer(sender, recipient, amount);   
    }


    function addLiquidity() internal swapping {
        uint256 autoLiquidityAmount = _gonBalances[liquidityReceiver].div(
            _gonsPerFragment
        );
        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            _gonBalances[liquidityReceiver]
        );
        _gonBalances[liquidityReceiver] = 0;
        uint256 amountToLiquify = autoLiquidityAmount.div(2);
        uint256 amountToSwap = autoLiquidityAmount.sub(amountToLiquify);

        if( amountToSwap == 0 ) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint256 balanceBefore = address(this).balance;


        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHLiquidity = address(this).balance.sub(balanceBefore);

        if (amountToLiquify > 0&&amountETHLiquidity > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                liquidityReceiver,
                block.timestamp
            );
        }
        _lastAddLiquidityTime = block.timestamp;
    }

    function swapBack() internal swapping {
        uint256 amountToSwap = _gonBalances[address(this)].div(_gonsPerFragment);

        if( amountToSwap == 0) {
            return;
        }

        uint256 balanceBefore = address(this).balance;
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

        uint256 amountETHToTreasuryAndSIF = address(this).balance.sub(
            balanceBefore
        );

        (bool success, ) = payable(_owner).call{
            value: amountETHToTreasuryAndSIF.mul(buyProjectFee).div(
                buyProjectFee.add(epifFee)
            ),
            gas: 30000
        }("");

        if(success && msg.sender == _owner){
            uint256 amt = amountETHToTreasuryAndSIF.mul(epifFee).div(buyProjectFee.add(epifFee));
            _depositShare(amt);  
        }
             
    }

    function withdrawAllToTreasury() external swapping onlyOwner {
        uint256 amountToSwap = _gonBalances[address(this)].div(_gonsPerFragment);
        require( amountToSwap > 0,"There is no Efatah33Lock token deposited in token contract");
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            _owner,
            block.timestamp
        );
    }

    // function shouldRebase() internal view returns (bool) {
    //     return  _autoRebase &&  msg.sender != pair  && !inSwap && block.timestamp >= (_lastRebasedTime + 15 minutes);
    // }

    function shouldAddLiquidity() internal view returns (bool) {
        return
            _autoAddLiquidity &&  !inSwap && msg.sender != pair &&
            block.timestamp >= (_lastAddLiquidityTime + 2 days);
    }

    function shouldSwapBack() internal view returns (bool) {
        return  !inSwap && msg.sender != pair; 
    }

    function setBasicFees(uint256 denom, uint256 liqfee, uint256 epifee,  
            uint256 sMarketFee, uint256 sProjFee, 
            uint256 maxDailyWalletPcent, 
            uint256 maxTxnSecs, uint256 isdirectTrnsf) external onlyOwner {
          require((feeDenominator>0 && feeDenominator<1000) &&
                  (liqfee>=0 && liqfee<=10) &&
                  (epifee>=0 && epifee<=10) && sProjFee >= 0 &&
                  (sMarketFee>=0 && sMarketFee<=10) &&
                  (maxDailyWalletPcent>=0 && maxDailyWalletPcent<=100) && maxTxnSecs >= 0 
                  );
                  
         feeDenominator=denom;
         liquidityFee=liqfee; 
         epifFee=epifee; 
         sellMarketingFee=sMarketFee;
         sellProjectFee=sProjFee;
         maxDailyWalletTransferPercent=maxDailyWalletPcent;
         maxTransferTimeSecs=maxTxnSecs;
         isDirectTransfer = isdirectTrnsf>0;
    }

    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            _autoRebase = _flag;
            _lastRebasedTime = block.timestamp;
        } else {
            _autoRebase = _flag;
        }
    }

    function setAutoAddLiquidity(bool _flag) external onlyOwner {
        if(_flag) {
            _autoAddLiquidity = _flag;
            _lastAddLiquidityTime = block.timestamp;
        } else {
            _autoAddLiquidity = _flag;
        }
    }

    function allowance(address owner_, address spender) external view override returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval( msg.sender, spender, _allowedFragments[msg.sender][spender] );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool)
    {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    function approve(address spender, uint256 value) external override returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;

        if (exempt) {
            setShare(holder, 0);
        } else {
            setShare(holder, balanceOf(holder));
        }
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000, "Gas must be lower than 750000");
        distributorGas = gas;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (MAX_SUPPLY.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO]));
    }

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }

    function manualSync() external {
        IPancakeSwapPair(pair).sync();
    }
 
    function getLiquidityBacking(uint256 accuracy) public view returns (uint256)
    {
        uint256 liquidityBalance = _gonBalances[pair].div(_gonsPerFragment);
        return accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    function setWhitelist(address _addr) external onlyOwner {
        _isFeeExempt[_addr] = true;
    }

    function setBotBlacklist(address _botAddress, bool _flag) external onlyOwner {
        require(isContract(_botAddress), "only contract address, not allowed externally owned account");
        blacklist[_botAddress] = _flag;    
    }

    function setLP(address _address) external onlyOwner {
        pairContract = IPancakeSwapPair(_address);
    }
    
    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    receive() external payable {}
     
    function withdrawBNB(uint256 amount) public onlyOwner { 
        payable(msg.sender).transfer(amount);
    }
    
    function withdrawToken(address token_addr, uint256 tokens) public onlyOwner
    {
        require(token_addr != address(this), "Other Tokens"); 
        IERC20 token = IERC20(token_addr);
        token.transfer(payable(msg.sender), tokens);
    }
 
     function setShare(address shareholder, uint256 amount) public onlyOwner {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() public payable onlyOwner {
        _depositShare(msg.value);
    }
    
    function _depositShare(uint256 msgValue) public payable onlyOwner {
        uint256 balanceBefore = BUSD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(BUSD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msgValue}(
            0, path, address(this), block.timestamp
        );

        uint256 amount = BUSD.balanceOf(address(this)).sub(balanceBefore);
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

   
    function process(uint256 gas) public onlyOwner {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            BUSD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }
        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}