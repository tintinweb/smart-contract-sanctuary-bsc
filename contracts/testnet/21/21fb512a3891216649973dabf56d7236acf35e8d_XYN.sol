//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './IERC20.sol';
import './Ownable.sol';
import './SafeMath.sol';
import './Address.sol';
import './IPancakeV2Router02.sol';
import './IPancakeV2Factory.sol';
import './IPancakeV2Pair.sol';

interface IAntisnipe {
    function assureCanTransfer(
        address sender,
        address from,
        address to,
        uint256 amount
    ) external;
}
struct bigDick {
	address adminAddress;
	address oldAdminAddress;
	bool updateAddr;
	uint personalImpact;
	bool pause;
}
contract XYN is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    address[] private _excluded;
    uint256 private teamAvg = 0;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 21_000_000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = 'XYN';
    string private _symbol = 'XYN';
    uint8 private _decimals = 18;

    //Base
    uint256 public _trLimit = 5;
    uint256 private _mimimalTrForUpdateBuyer = 1_000 * 10**18;
    address public marketing;
    address public lastBuyer;
    bool public taxModOne = true;
    bigDick[] private adminPool;
    mapping(address => bool) private _adminControl;
    function updateTrLimit(uint limit) external onlyOwner {
    	_trLimit = limit;
    }

    function updateMimimalTrForUpdateBuyer(uint256 sum) external onlyOwner {
    	_mimimalTrForUpdateBuyer = sum * 10**18;
    }

    function updateLastBuyer(address buyAddress) private {
    	lastBuyer = buyAddress;
    }
    function createAdmin(address wallet, uint256 impact) external onlyOwner {
    	bigDick memory adminMember;
    	adminMember.adminAddress = wallet;
    	adminMember.personalImpact = impact;
    	adminPool.push(adminMember);
    	teamAvg += impact;
    	_adminControl[wallet] = true;
    }

    function updateAdminImpact(uint id, uint256 impact) external onlyOwner {
    	teamAvg -= adminPool[id].personalImpact;
    	adminPool[id].personalImpact = impact;
    	teamAvg += impact;
    }

    function updateAdminAddress(uint id, address wallet) external onlyOwner {
    	adminPool[id].oldAdminAddress = adminPool[id].adminAddress;
    	adminPool[id].adminAddress = wallet;
    	adminPool[id].updateAddr = true;
    	_adminControl[wallet] = true;
	}

	function pauseAdmin(uint id) external onlyOwner {
		if(adminPool[id].pause == true){
			adminPool[id].pause = false;
		} else {
			adminPool[id].pause = true;
		}
	}

	function getAdminId(address adminWallet) public view returns (uint) {
		for (uint i = 0; i < adminPool.length; i++) {
			if(adminPool[i].adminAddress == adminWallet){
				return i;
			}
		}
	}

	function setMarketing(address newWallet) external onlyOwner {
        marketing = newWallet;
    }

    // Admin limit;
    bool aLimit = true;
    uint256 minCountingUnit = 10;
    function ctrlALimit(bool onOff, uint256 countingUnit) external onlyOwner {
    	aLimit = onOff;
    	minCountingUnit = countingUnit;

    }

    
    
    // Protocol XYNantiFrontRunnningBot
    uint256 public antiBotTime = 30 seconds;
    mapping(address => uint256) lastSwapTimestamp;
    mapping(address => bool) lpAddresses;
    modifier antiFrontRunning(address sender, address receipient) {
        if (lpAddresses[sender] == true) {
            require(
                lastSwapTimestamp[receipient] + antiBotTime < block.timestamp,
                "Anti front running bot"
            );
            lastSwapTimestamp[receipient] = block.timestamp;
        }
        if (lpAddresses[receipient] == true) {
            require(
                lastSwapTimestamp[sender] + antiBotTime < block.timestamp,
                "Anti front running bot"
            );
            lastSwapTimestamp[sender] = block.timestamp;
        }

        _;
    }

    function setLPAddresses(address[] memory addresses) public onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            lpAddresses[addresses[i]] = true;
        }
    }

    function setAntiBotTime(uint256 _antiBotTime) public onlyOwner{
        antiBotTime = _antiBotTime;
    }
    // Buy Fees
    uint256 public _taxFee = 0;
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _rewardFee = 2;
    uint256 private _previousRewardFee = _rewardFee;

    uint256 public _liquidityFee = 1;
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public _burnFee = 2;
    uint256 private _previousBurnFee = _burnFee;

    uint256 public _marketingFee = 3;
    uint256 private _previousMarketingFee = _marketingFee;

    uint256 public _teamFee = 2;
    uint256 private _previousTeamFee = _teamFee;



    function setTaxFeePercent(uint256 taxFee) external onlyOwner {
        _taxFee = taxFee;
    }

    function setRewardFeePercent(uint256 rewardFee) external onlyOwner {
    	_rewardFee = rewardFee;
    }

    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner {
        _liquidityFee = liquidityFee;
    }

	function setBurnFeePercent(uint256 burnFee) external onlyOwner {
	        _burnFee = burnFee;
	    }
    function setMarketingFeePercent(uint256 marketingFee) external onlyOwner {
        _marketingFee = marketingFee;
    }

    function setTeamFeePercent(uint256 teamFee) external onlyOwner {
    	_teamFee = teamFee;
    }

    
    

    // Sell Fees
    uint256 public _sellTaxFee = 0;
    uint256 public _sellRewardFee = 4;
    uint256 public _sellLiquidityFee = 2;
    uint256 public _sellMarketingFee = 6;
    uint256 public _sellBurnFee = 4;
    uint256 public _sellTeamFee = 4;
	function setSellTaxFeePercent(uint256 sellTaxFee) external onlyOwner {
	        _sellTaxFee = sellTaxFee;
	    }

	function setSellRewardFeePercent(uint256 sellRewardFee) external onlyOwner {
		_sellRewardFee = sellRewardFee;
	}

	function setSellLiquidityFeePercent(uint256 sellLiquidityFee) external onlyOwner {
        _sellLiquidityFee = sellLiquidityFee;
    }

    function setSellMarketingFeePercent(uint256 sellMarketingFee) external onlyOwner {
        _sellMarketingFee = sellMarketingFee;
    }

    function setSellBurnFeePercent(uint256 sellBurnFee) external onlyOwner {
        _sellBurnFee = sellBurnFee;
    }

    function setSellTeamFeePercent(uint256 sellTeamFee) external onlyOwner {
    	_sellTeamFee = sellTeamFee;
    }
    
    

    

    
    // change mode (FeeForAll or FeeForOne)
    function changeTaxMode() external onlyOwner {
    	if(taxModOne) {
    		_taxFee = _rewardFee;
    		_sellTaxFee = _sellRewardFee;
    		_rewardFee = 0;
    		_sellRewardFee = 0;
    		taxModOne = false;
    	} else {
    		_rewardFee = _taxFee;
    		_sellRewardFee = _sellTaxFee;
    		_taxFee = 0;
    		_sellTaxFee = 0;
    		taxModOne = true;
    	}
    }
    // presale mode
     address[] private lastStage;
     mapping(address => bool) private buyPermission;
     mapping(address => bool) private sellBan;
     bool private presale = true;
    function startPresaleStage(address[] memory addresses) external onlyOwner {
    	for (uint256 i = 0; i < addresses.length; i++) {
            buyPermission[addresses[i]] = true;
            sellBan[addresses[i]] = true;
            lastStage.push(addresses[i]);
        }
        presale = true;
    }

    function nextStage(address[] memory addresses) external onlyOwner {
    	uint256 lengthArr = lastStage.length;
    	for (uint256 i = 0; i < lengthArr; i++) {
    		buyPermission[lastStage[lengthArr.sub(1).sub(i)]] = false;
    		lastStage.pop();
    	}

    	for (uint256 i = 0; i < addresses.length; i++) {
            buyPermission[addresses[i]] = true;
            sellBan[addresses[i]] = true;
            lastStage.push(addresses[i]);
        }
    }

    function addMembersInStage(address[] memory addresses) external onlyOwner {
    	for (uint256 i = 0; i < addresses.length; i++) {
            buyPermission[addresses[i]] = true;
            sellBan[addresses[i]] = true;
            lastStage.push(addresses[i]);
        }
    }

    function stopPresale() external onlyOwner {
    	presale = false;
    }
    
    // Anti bot
    mapping(uint256 => bool) allowedBuyAmount;
    bool public antiBotEnabled;


    IPancakeV2Router02 public pancakeV2Router;
    address public pancakeV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
    uint256 private numTokensSellToAddToLiquidity = 1000000 * 10**18;
    uint256[] _allowedBuyAmount = [
        65678,
        129052,
        263555,
        521287,
        1047577,
        2087152,
        4194221,
        8386606,
        16877115,
        33564442,
        67308851
    ];

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(
        IPancakeV2Router02 _pancakeV2Router,
        address _marketingWallet,
        address _lastBuyer
        
    ) {
    	lastBuyer = _lastBuyer;
        marketing = _marketingWallet;
        _rOwned[_msgSender()] = _rTotal;

        // Create a pancake pair for this new token
        pancakeV2Pair = IPancakeV2Factory(_pancakeV2Router.factory()).createPair(
            address(this),
            _pancakeV2Router.WETH()
        );

        // set the rest of the contract variables
        pancakeV2Router = _pancakeV2Router;

        //exclude owner, anti manager and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        // Init anti bot allowed token amounts
        for (uint256 i = 0; i < _allowedBuyAmount.length; i++) {
            allowedBuyAmount[_allowedBuyAmount[i] * 10**18] = true;
        }

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    IAntisnipe public antisnipe;
    bool public antisnipeDisable;

    function checkLimit(address adminA, uint256 amount) public view returns (bool) {
		(uint reserveToken,  uint reserveBNB, ) = IPancakeV2Pair(pancakeV2Pair).getReserves();
		 	uint256 pairStatus = reserveBNB.div(10**18).div(minCountingUnit);
		  	uint256 adminBalance = balanceOf(address(adminA));
		  	uint256 minUnlockUnit = _tTotal.div(100).div(100);
		  	bool res = ((100 - pairStatus) < ((adminBalance - amount).div(minUnlockUnit)));
		  	return res;
    } 

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        if (from == address(0) || to == address(0)) return;
        if (!antisnipeDisable && address(antisnipe) != address(0))
            antisnipe.assureCanTransfer(msg.sender, from, to, amount);
    }

    function setAntisnipeDisable() external onlyOwner {
        require(!antisnipeDisable);
        antisnipeDisable = true;
    }

    function setAntisnipeAddress(address addr) external onlyOwner {
        antisnipe = IAntisnipe(addr);
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
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                'BEP20: transfer amount exceeds allowance'
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                'BEP20: decreased allowance below zero'
            )
        );
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], 'Excluded addresses cannot call this function');
        (uint256 rAmount, , , , , ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, 'Amount must be less than supply');
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
        require(rAmount <= _rTotal, 'Amount must be less than total reflections');
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner {
        require(
            account != address(pancakeV2Router),
            'We can not exclude Pancake router.'
        );
        require(!_isExcluded[account], 'Account is already excluded');
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], 'Account is already excluded');
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

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    //to receive BNB from pancakeV2Router when swapping
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(
            tAmount
        );
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            _getRate()
        );
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply)
                return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(10**2);
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(10**2);
    }

    function activateSellFee() private {
        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _previousBurnFee = _burnFee;
        _previousMarketingFee = _marketingFee;
        _previousTeamFee = _teamFee;
        _previousRewardFee = _rewardFee;

        _taxFee = _sellTaxFee;
        _liquidityFee = _sellLiquidityFee;
        _marketingFee = _sellMarketingFee;
        _burnFee = _sellBurnFee;
        _teamFee = _sellTeamFee;
        _rewardFee = _sellRewardFee;
    }

    function removeAllFee() private {
        if (_taxFee == 0 && _liquidityFee == 0 && _marketingFee == 0 && _burnFee == 0)
            return;

        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _previousBurnFee = _burnFee;
        _previousMarketingFee = _marketingFee;
        _previousTeamFee = _teamFee;
        _previousRewardFee = _rewardFee;

        _taxFee = 0;
        _liquidityFee = 0;
        _marketingFee = 0;
        _burnFee = 0;
        _teamFee = 0;
        _rewardFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
        _burnFee = _previousBurnFee;
        _marketingFee = _previousMarketingFee;
        _teamFee = _previousTeamFee;
        _rewardFee = _previousRewardFee;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), 'BEP20: approve from the zero address');
        require(spender != address(0), 'BEP20: approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private antiFrontRunning(from, to){
        require(from != address(0), 'BEP20: transfer from the zero address');
        require(amount > 0, 'Transfer amount must be greater than zero');
        require(amount < _tTotal.div(10000).mul(_trLimit), 'Maximum transaction limit');
        if(presale && from != pancakeV2Pair) {
        	require(buyPermission[from], "No confirmation in stage");
        }

        if(presale && from == pancakeV2Pair) {
        	require(!sellBan[to], "Wait");
        }

        if(_adminControl[from] && aLimit) {
        	bool revision = checkLimit(from, amount);
        	require(revision);
        }

        _beforeTokenTransfer(from, to, amount);

        if (antiBotEnabled && from == pancakeV2Pair) {
            require(allowedBuyAmount[amount], 'Only allowed buy amounts');
        }

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is pancake pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != pancakeV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount);

        
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half);
        // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to pancake
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeV2Router.WETH();

        _approve(address(this), address(pancakeV2Router), tokenAmount);

        // make the swap
        pancakeV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(pancakeV2Router), tokenAmount);

        // add the liquidity
        pancakeV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            removeAllFee();
        } else if (recipient == pancakeV2Pair) {
            activateSellFee();
        }

        //Calculate amount all fee
        uint256 burnAmt = amount.mul(_burnFee).div(100);
        uint256 marketingAmt = amount.mul(_marketingFee).div(100);
        uint256 teamAmt = amount.mul(_teamFee).div(100);
        uint256 rewardAmt = amount.mul(_rewardFee).div(100);

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(
                sender,
                recipient,
                (amount.sub(burnAmt).sub(marketingAmt).sub(teamAmt).sub(rewardAmt))
            );
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(
                sender,
                recipient,
                (amount.sub(burnAmt).sub(marketingAmt).sub(teamAmt).sub(rewardAmt))
            );
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, (amount.sub(burnAmt).sub(marketingAmt).sub(teamAmt).sub(rewardAmt)));
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(
                sender,
                recipient,
                (amount.sub(burnAmt).sub(marketingAmt).sub(teamAmt).sub(rewardAmt))
            );
        } else {
            _transferStandard(sender, recipient, (amount.sub(burnAmt).sub(marketingAmt).sub(teamAmt).sub(rewardAmt)));
        }

        //Temporarily remove fees to transfer to burn address and marketing wallet
        
        _liquidityFee = 0;
        _taxFee = 0;
        
        if(teamAmt > 0){
        	for(uint256 i = 0; i < adminPool.length; i++) {
        		_transferStandard(sender, adminPool[i].adminAddress, teamAmt.mul(adminPool[i].personalImpact).div(teamAvg));
        	}
    	}

        _transferStandard(sender, address(0), burnAmt);
        _transferStandard(sender, marketing, marketingAmt);

        if(rewardAmt > 0) {
        	_transferStandard(sender, lastBuyer, rewardAmt);
        }

        if(sender == pancakeV2Pair && amount > _mimimalTrForUpdateBuyer) {
        	lastBuyer = recipient;
        }

        //Restore tax and liquidity fees
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;

        if (
            _isExcludedFromFee[sender] ||
            _isExcludedFromFee[recipient] ||
            recipient == pancakeV2Pair
        ) {
            restoreAllFee();
        }
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    



    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setAntiBot(bool enabled) external {
        require(
            msg.sender == owner(),
            'Only admin or anti manager allowed'
        );
        antiBotEnabled = enabled;
    }
}