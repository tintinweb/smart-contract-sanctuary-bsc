/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

/*

█▀▀ █▀▀█ █── █── ▀▀█▀▀ █▀▀█ █▀▀ █▀▀█ █▀▄▀█ █▀▀▄ █▀▀█ ▀▀█▀▀ 
█── █▄▄█ █── █── ──█── █──█ █── █──█ █─▀─█ █▀▀▄ █▄▄█ ──█── 
▀▀▀ ▀──▀ ▀▀▀ ▀▀▀ ──▀── ▀▀▀▀ ▀▀▀ ▀▀▀▀ ▀───▀ ▀▀▀─ ▀──▀ ──▀── 

░█▀▀█ █── █▀▀█ █──█ 　 ▀▀█▀▀ █▀▀█ 　 █▀▀ █▀▀█ █▀▀█ █▀▀▄ 
░█▄▄█ █── █▄▄█ █▄▄█ 　 ──█── █──█ 　 █▀▀ █▄▄█ █▄▄▀ █──█ 
░█─── ▀▀▀ ▀──▀ ▄▄▄█ 　 ──▀── ▀▀▀▀ 　 ▀▀▀ ▀──▀ ▀─▀▀ ▀──▀

##CALLTOCOMBAT

+++++++++++++++Tokenomics
>> 5% BUY TAX
>> 15% SELL TAX
>> TOTAL SUPPLY 100,000,000 $CTC
>> DEV CANNOT SET MAX FEE 100%
>> AUTOMATIC IDO UNLOCK
>> NO MINT
>> REWARDING HOLDERS BUSD WITH NO REBASE!!!!!

+++++++++++++++Tax Breakdown
>> 15% BUY OR SELL TAX SENT TO INSURANCE RESERVE
>> 5% BUY OR SELL TAX AUTOMATICALLY BURNED
>> 85% BUY OR SELL TAX SENT TO REWARD ALL HOLDERS

+++++++++++++++Socials
Github >> https://github.com/calltocombat
Telegram Chat >> https://t.me/calltocombat
Telegram News >> https://t.me/calltocombatnews
Twitter >> https://twitter.com/combatcall
Youtube >> https://www.youtube.com/channel/UCbyecUgKyKvLKJU1OIczbyg
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.0;



/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
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

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
	
	function swapExactETHForTokens(
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

interface readIDOContract {
  function getIDOAmount(address _address) external view returns (uint256);
}


contract CALLTOCOMBAT is IBEP20, Auth {
    using SafeMath for uint256;

    uint256 public constant MASK = type(uint128).max;
    address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
	address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "CALLTOCOMBAT";
    string constant _symbol = "CTC";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 100_000_000 * (10 ** _decimals);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isFeeExempt;

  
    uint256 public totalbuyFee = 5; //general buy tax
	uint256 public totalsellFee = 15; //general sell tax
	
	uint256 public insuranceFee = 15;
	uint256 public burnFee = 5; 
	uint256 public rewardsFee = 80;
	uint256 tFeeTotal;
	
	uint256 maxtotalbuyFee = 10; //NOTE:<--prevent dev from exceeding this level set buy fee!
	uint256 maxtotalsellFee = 20; //NOTE:<--prevent dev from exceeding this level set sell fee!
	uint256 feeDenominator = 100; //100%
	uint256 public unlocktimestamp;
	
	uint256 public swapThreshold; 


    address public rewardscontractReceiver; 
    address public insuranceFundReceiver;
	address public idoContract; //NOTE:<--bookkeeping for IDO. will be ejected automatically after the unlock time. (end of IDO)
	

    IDEXRouter public router;
    address public pair;

    uint256 public launchedAt;
    uint256 public launchedAtTimestamp;


    bool inSwap;
    bool public swapEnabled = true;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor (
        address _dexRouter
    ) Auth(msg.sender) {
        router = IDEXRouter(_dexRouter);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = _totalSupply;
        WBNB = router.WETH();
        isFeeExempt[msg.sender] = true;

        rewardscontractReceiver = msg.sender;
        insuranceFundReceiver = msg.sender;
        unlocktimestamp = block.timestamp;
		swapThreshold = _totalSupply.div(10000); //0.01% required token to swap back
        approve(_dexRouter, _totalSupply);
        approve(address(pair), _totalSupply);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { } //to receive BNB from pcs

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _tokentransfer(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != _totalSupply){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _tokentransfer(sender, recipient, amount);
    }

    function _tokentransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
		if (idoContract != address(0)) {
                uint256 totalPurchasedAmount = readIDOContract(idoContract).getIDOAmount(sender);
                require(balanceOf(sender).sub(amount) >= totalPurchasedAmount, "$CTC tokens purchased during IDO cannot be transferred yet.");
            }
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(shouldSwapBack()){ swapBack(); } //this initiates the buy back from contract balance
		
		if(shouldUnlock()){ forceUnlock(); } //this initiates the Automatic Unlock of Locked IDO Tokens

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
	

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
		emit Transfer(sender, recipient, amount);
        return true;
    }


    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }


    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        //check and collect fees!!--dump fees into contract to be utilized!
		if (sender == pair) {
        uint256 feeAmountperc = totalbuyFee; 
		uint256 feeAmount = feeAmountperc.mul(amount).div(feeDenominator); 
		tFeeTotal += feeAmount;
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
		}
		else if (receiver == pair) {
		uint256 feeAmountperc = totalsellFee; 
		uint256 feeAmount = feeAmountperc.mul(amount).div(feeDenominator);
        tFeeTotal += feeAmount;		
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
		} else {
		//dont take fees on regular (wallet to wallet) token transfers
        return amount;
		}
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }
	

    function swapBack() internal swapping {
		/*
		   *We will split the token balance into three parts for each fee. 
		   *and deal with each part individually - it just uses a bit more gas :(
		*/
		uint256 initialTokenBalance = balanceOf(address(this)); //capture initial contract token balance
		uint256 amountToBurn = initialTokenBalance.mul(burnFee).div(feeDenominator);
        uint256 amountToSwapBUSD =initialTokenBalance.mul(rewardsFee).div(feeDenominator);
		uint256 amountToSwapBNB =initialTokenBalance.mul(insuranceFee).div(feeDenominator);
		/*
		   *We will assume that all tokens in contract balance are fees and swap everything.. 
		   *anyone that manually sends tokens to contact simply donated more fees to the community :)
		*/
		//lets Burn
		_balances[address(this)] = _balances[address(this)].sub(amountToBurn);
		_balances[DEAD] = _balances[DEAD].add(amountToBurn);
        emit Transfer(address(this), DEAD, amountToBurn);
		
		//lets GETBNB and send to insurance
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;
        uint256 balanceBefore = address(this).balance; //capture initial bnb balance

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwapBNB,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountBNB = address(this).balance.sub(balanceBefore); //exact bnb that was added
        payable(insuranceFundReceiver).transfer(amountBNB);

        //lets GETBUSD with BNB and send to rewards
        uint256 balanceAfterFirstSwap = address(this).balance; //capture again bnb balance

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwapBUSD,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountBNBtoBUSD = address(this).balance.sub(balanceAfterFirstSwap); //exact bnb that was added to balance
        
		//lets get BUSD to rewardscontractReceiver
		buyTokenBusd(amountBNBtoBUSD, rewardscontractReceiver);
      }
	  
	function shouldUnlock() internal view returns (bool) {
		return block.timestamp >= unlocktimestamp 
		&& idoContract != address(0);
	}
	
	function forceUnlock() internal {
		/*
		   *After the IDO is ended, If unlock time is reached, the contract automatically Ejects the IDO contract to unlock IDO tokens
		*/
		idoContract = address(0);
	}
	
	function SetIDOContract(address _idoContract) external authorized {
		/*
		   *Once the IDO contract and Future Unlock Time is set by DEV, it cannot be replaced by DEV until unlock time is reached.
		   *Once the future unlock time is set by DEV, it can not be changed until the SET time is elapsed.
		*/
		require(block.timestamp >= unlocktimestamp, "cannot SET or Replace IDO contract during a current IDO Sale.");
		idoContract = _idoContract;
	}
	
	function SetUnlockTimestamp(uint256 _timestamp) external authorized {
		require(block.timestamp >= unlocktimestamp, "initial SET timestamp must be exceeded before the dev will be able to set a new timestamp");
		unlocktimestamp = _timestamp;
	}

	
	function buyTokenBusd(uint256 amount, address to) internal swapping { 
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = BUSD;

        router.swapExactETHForTokens{value: amount}(
            0,
            path,
            to,
            block.timestamp
        );
    }
	
	function RolloverRewards() external {
		buyTokenBusd(address(this).balance, rewardscontractReceiver);
	}
	
	
	function withdrawStuckToken(address recipient, address token) external authorized {
        //allows stuck tokens ERC20 to be ejected from this contract.
		require(token != address(this), "Cannot Withdraw Own Token");
        IBEP20(token).transfer(recipient, IBEP20(token).balanceOf(address(this)));
    }


    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }


    function launch() public authorized {
        require(launchedAt == 0, "CALLTOCOMBAT WAS LAUNCHED ALREADY");
        launchedAt = block.number;
        launchedAtTimestamp = block.timestamp;
    }


    function ExcludeFees(address holder) external authorized {
        require(!isFeeExempt[holder], "holder is already excluded from Fees");
        isFeeExempt[holder] = true;
    }

	function includeFees(address holder) external authorized {
        require(isFeeExempt[holder], "holder is not excluded from Fees");
        isFeeExempt[holder] = false;
    }
	

    function setBuyAndSellFees(uint256 _buyFee, uint256 _sellFee) external authorized {
        require(_buyFee <= maxtotalbuyFee && _sellFee <= maxtotalsellFee, "Sorry Dev, You cant set above Max Fees");
		totalbuyFee = _buyFee;
        totalsellFee = _sellFee;
    }
	
	
	function setIndividualFeePercentages(uint256 _insuranceFee, uint256 _burnFee, uint256 _rewardsFee) external authorized {
        require(_insuranceFee + _burnFee + _rewardsFee == feeDenominator, "please Re-Arragne inividual Fees");
		insuranceFee = _insuranceFee;
        burnFee = _burnFee;
		rewardsFee = _rewardsFee;
    }

    function setFeeReceivers(address _rewardscontractReceiver, address _insuranceFundReceiver) external authorized {
        rewardscontractReceiver = _rewardscontractReceiver;
        insuranceFundReceiver = _insuranceFundReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }


    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }
	
	function totalFees() public view returns (uint256) {
        return tFeeTotal;
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }


}