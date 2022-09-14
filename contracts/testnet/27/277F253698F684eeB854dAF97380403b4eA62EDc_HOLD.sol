// File: contracts/protocols/HODL.sol

pragma solidity >=0.8.7;

import "./ReentrancyGuard.sol";
import "./Utils.sol";
import "./IFiles.sol";


pragma experimental ABIEncoderV2;

contract HOLD is Context, IBEP20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    mapping(address => bool) private _isExcludedFromMaxTx;

    // trace BNB claimed rewards and reinvest value
    mapping(address => uint256) public userClaimedBNB;
    uint256 public totalClaimedBNB;

    mapping(address => uint256) public userreinvested;
    uint256 public totalreinvested;

    // trace gas fees distribution
    uint256 public totalgasfeesdistributed;
    mapping(address => uint256) public userrecievedgasfees;

    address public deadAddress;

    address[] private _excluded;

    uint256 private MAX;
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    IPancakeRouter02 public pancakeRouter;
    address public pancakePair;

    bool private _inSwapAndLiquify;

    uint256 private daySeconds;

    struct WalletAllowance {
        uint256 timestamp;
        uint256 amount;
    }

    mapping(address => WalletAllowance) userWalletAllowance;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event ClaimBNBSuccessfully(
        address recipient,
        uint256 ethReceived,
        uint256 nextAvailableClaimDate
    );

    modifier lockTheSwap() {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    constructor() {}

    mapping(address => bool) isBlacklisted;

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

    function transfer(address recipient, uint256 amount) public override returns (bool){
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool){
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
                "BEP20: transfer amount exceeds allowance"
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
                "BEP20: decreased allowance below zero"
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
        require(
            !_isExcluded[sender],
            "Excluded addresses cannot call this function"
        );
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
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Pancake router.');
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is already excluded");
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

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setTaxFeePercent(uint256 taxFee) external onlyOwner {
        _taxFee = taxFee;
    }

    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner {
        _liquidityFee = liquidityFee;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    //to receive BNB from pancakeRouter when swapping
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
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            _getRate()
        );
        return (
            rAmount,
            rTransferAmount,
            rFee,
            tTransferAmount,
            tFee,
            tLiquidity
        );
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
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
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
        return _amount.mul(_taxFee).div(10**3);
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256){
        return _amount.mul(_liquidityFee).div(10**3);
    }

    /*
    function checkTaxAndLiquidityFees() private view returns (bool) {
         return block.timestamp > disruptiveTransferEnabledFrom.add(daySeconds.mul(2));
    }
    */

    function removeAllFee() private {
        if (_taxFee == 0 && _liquidityFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;

        _taxFee = 0;
        _liquidityFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        //require(!isBlacklisted[from], "Sender is backlisted");
        //require(!isBlacklisted[to], "Recipient is backlisted");
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (
            _isExcludedFromFee[from] ||
            _isExcludedFromFee[to] ||
            reflectionFeesDisabled
        ) {
            takeFee = false;
        }

        // take sell fee
        if (
            pairAddresses[to] &&
            from != address(this) &&
            from != owner()
        ) {
            uint256 _antiFlipTax = antiFlipTax[Utils.getAntiFlipTaxNo(firstBuyTimeStamp[from])];
            ensureMaxTxAmount(from, to, amount);
            _taxFee = selltax.add(_antiFlipTax).mul(_Reflection).div(100); 
            _liquidityFee = selltax.add(_antiFlipTax).mul(_Tokenomics).div(100);
            if (!_inSwapAndLiquify) {
                swapAndLiquify(from, to);
            }
        }
        
        // take buy fee
        else if (
            pairAddresses[from] && to != address(this) && to != owner()
        ) {
                /*
            if (!checkTaxAndLiquidityFees()) {
                _taxFee = buytax.mul(_Reflection).div(100).div(2);
                _liquidityFee = buytax.mul(_Tokenomics).div(100).div(2);
            } else {
                */
                if (balanceOf(to) == 0) {
                    firstBuyTimeStamp[to] = block.timestamp;
                }
                _taxFee = buytax.mul(_Reflection).div(100);
                _liquidityFee = buytax.mul(_Tokenomics).div(100);
            //}
        }
        
        // take transfer fee
        else {
            if (takeFee && from != owner() && from != address(this)) {
                _taxFee = transfertax.mul(_Reflection).div(100);
                _liquidityFee = transfertax.mul(_Tokenomics).div(100);
            }
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();

        // top up claim cycle for recipient and sender
        topUpClaimCycleAfterTransfer(sender, recipient, amount);

        // top up claim cycle for sender
        //topUpClaimCycleAfterTransfer(sender, amount);

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

        if (!takeFee) restoreAllFee();
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

    // Innovation for protocol by HODL Team
    uint256 public rewardCycleBlock;
    uint256 private stackingCounterStart;
    uint256 public threshHoldTopUpRate;
    uint256 public _maxTxAmount;
    uint256 public bnbStackingLimit;
    mapping(address => uint256) public nextAvailableClaimDate;
    bool public swapAndLiquifyEnabled;
    uint256 private reserve_5;
    uint256 private reserve_6;

    bool public reflectionFeesDisabled;

    uint256 private _taxFee;
    uint256 private _previousTaxFee;

    uint256[6] public antiFlipTax;

    LayerTax public bnbClaimTax;

    struct LayerTax {
        uint256 layer1;
        uint256 layer2;
        uint256 layer3;
        uint256 layer4;
        uint256 layer5;
        uint256 layer6;
    }

    uint256 public selltax;
    uint256 public buytax;
    uint256 public transfertax;

    uint256 public claimBNBLimit;
    uint256 public reinvestLimit;
    uint256 private reserve_1;

    address public reservewallet;
    address public teamwallet;
    address public marketingwallet;
    address private stackingWallet;
    
    uint256 private _liquidityFee;
    uint256 private _previousLiquidityFee;

    uint256 public minTokenNumberToSell; 
    uint256 public minTokenNumberUpperlimit;

    uint256 public rewardHardcap;

    Tokenomics public tokenomics;
    
    struct Tokenomics {
        uint256 bnbReward;
        uint256 liquidity;
        uint256 marketing;
        uint256 reflection;
        uint256 reserve;
    }

    uint256 private _Reflection;
    uint256 private _Tokenomics;

    address public triggerwallet;

    mapping(address => bool) public pairAddresses;

    address public HodlMasterChef;

    mapping(address => uint256) public firstBuyTimeStamp;

    //Stacking
    struct stacking {
        bool enabled;
        uint64 cycle;
        uint64 tsStartStacking;
        uint64 stackingCounter;
        uint96 stackingLimit;
        uint96 amount;
        uint96 hardcap;   
    }
    mapping(address => stacking) public rewardStacking;
    bool public stackingEnabled;

    function setMaxTxPercent(uint256 maxTxPercent) public onlyOwner {
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(100000);
    }

    function setExcludeFromMaxTx(address _address, bool value) public onlyOwner{
        _isExcludedFromMaxTx[_address] = value;
    }

    function calculateBNBReward(address ofAddress) public view returns (uint256){
        uint256 totalsupply = uint256(_tTotal)
            .sub(balanceOf(address(0)))
            .sub(balanceOf(0x000000000000000000000000000000000000dEaD)) // exclude burned wallet
            .sub(balanceOf(address(pancakePair))); // exclude liquidity wallet
        
        return Utils.calculateBNBReward(
                balanceOf(address(ofAddress)),
                address(this).balance,
                totalsupply,
                rewardHardcap
            );
    }

    /*
    function getRewardCycleBlock() public view returns (uint256) {
        if (block.timestamp >= disableEasyRewardFrom) return rewardCycleBlock;
        return easyRewardCycleBlock;
    }
    */

    function redeemRewards(uint256 perc) public isHuman nonReentrant {
        require(nextAvailableClaimDate[msg.sender] <= block.timestamp, "Error: next available not reached");
        require(balanceOf(msg.sender) >= 0, "Error: must own HODL to claim reward");

        uint256 totalsupply = uint256(_tTotal)
            .sub(balanceOf(address(0)))
            .sub(balanceOf(0x000000000000000000000000000000000000dEaD)) // exclude burned wallet
            .sub(balanceOf(address(pancakePair))); // exclude liquidity wallet
        uint256 currentBNBPool = address(this).balance;

        uint256 reward = currentBNBPool > rewardHardcap ? rewardHardcap.mul(balanceOf(msg.sender)).div(totalsupply) : currentBNBPool.mul(balanceOf(msg.sender)).div(totalsupply);

        uint256 rewardreinvest;
        uint256 rewardBNB;

        if (perc == 100) {
            require(reward > claimBNBLimit, "Reward below gas fee");
            rewardBNB = reward;
        } else if (perc == 0) {     
            rewardreinvest = reward;
        } else {
            rewardBNB = reward.mul(perc).div(100);
            rewardreinvest = reward.sub(rewardBNB);
        }

        // BNB REINVEST
        if (perc < 100) {
            
            require(reward > reinvestLimit, "Reward below gas fee");

            // Re-InvestTokens
            uint256 expectedtoken = Utils.getAmountsout(rewardreinvest, address(pancakeRouter));

            // update reinvest rewards
            userreinvested[msg.sender] += expectedtoken;
            totalreinvested += expectedtoken;

            _tokenTransfer(address(this), msg.sender, expectedtoken, false);
        }

        // BNB CLAIM
        if (rewardBNB > 0) {
            uint256 rewardfee;
            bool success;
            // deduct tax
            if (rewardBNB < 0.1 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer1).div(100);
            } else if (rewardBNB < 0.25 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer2).div(100);
            } else if (rewardBNB < 0.5 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer3).div(100);
            } else if (rewardBNB < 0.75 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer4).div(100);
            } else if (rewardBNB < 1 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer5).div(100);
            } else {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer6).div(100);
            }
            rewardBNB -= rewardfee;
            (success, ) = address(reservewallet).call{value: rewardfee}("");
            require(success, " Error: Cannot send reward");

            // send bnb to user
            (success, ) = address(msg.sender).call{value: rewardBNB}("");
            require(success, "Error: Cannot withdraw reward");

            // update claimed rewards
            userClaimedBNB[msg.sender] += rewardBNB;
            totalClaimedBNB += rewardBNB;
        }

        // update rewardCycleBlock
        nextAvailableClaimDate[msg.sender] = block.timestamp + rewardCycleBlock;
        emit ClaimBNBSuccessfully(msg.sender,reward,nextAvailableClaimDate[msg.sender]);
    }

    function topUpClaimCycleAfterTransfer(address _sender, address _recipient, uint256 amount) private {
        //_recipient
        uint256 currentBalance = balanceOf(_recipient);
        if ((_recipient == owner() && nextAvailableClaimDate[_recipient] == 0) || currentBalance == 0) {
                nextAvailableClaimDate[_recipient] = block.timestamp + rewardCycleBlock;
        } else {
            nextAvailableClaimDate[_recipient] += Utils.calculateTopUpClaim(
                                                currentBalance,
                                                rewardCycleBlock,
                                                threshHoldTopUpRate,
                                                amount);
            if (nextAvailableClaimDate[_recipient] > block.timestamp + rewardCycleBlock) {
                nextAvailableClaimDate[_recipient] = block.timestamp + rewardCycleBlock;
            }
        }

        //sender
        if (_recipient != HodlMasterChef) {
            currentBalance = balanceOf(_sender);
            if ((_sender == owner() && nextAvailableClaimDate[_sender] == 0) || currentBalance == 0) {
                    nextAvailableClaimDate[_sender] = block.timestamp + rewardCycleBlock;
            } else {
                nextAvailableClaimDate[_sender] += Utils.calculateTopUpClaim(
                                                    currentBalance,
                                                    rewardCycleBlock,
                                                    threshHoldTopUpRate,
                                                    amount);
                if (nextAvailableClaimDate[_sender] > block.timestamp + rewardCycleBlock) {
                    nextAvailableClaimDate[_sender] = block.timestamp + rewardCycleBlock;
                }                                     
            }
        }
    }

    function ensureMaxTxAmount(address from, address to, uint256 amount) private {
        if (
            _isExcludedFromMaxTx[from] == false && // default will be false
            _isExcludedFromMaxTx[to] == false // default will be false
        ) {
            //if (value < disruptiveCoverageFee && block.timestamp >= disruptiveTransferEnabledFrom) { 
                WalletAllowance storage wallet = userWalletAllowance[from];

                if (block.timestamp > wallet.timestamp.add(daySeconds)) {
                    wallet.timestamp = 0;
                    wallet.amount = 0;
                }

                uint256 totalAmount = wallet.amount.add(amount);

                require(
                    totalAmount <= _maxTxAmount,
                    "Amount is more than the maximum limit"
                );

                if (wallet.timestamp == 0) {
                    wallet.timestamp = block.timestamp;
                }

                wallet.amount = totalAmount;
            //}
        }
    }

    /*
    function disruptiveTransfer(address recipient, uint256 amount) public payable returns (bool){
        _transfer(_msgSender(), recipient, amount, msg.value);
        return true;
    }
    */

    function swapAndLiquify(address from, address to) private lockTheSwap {

        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 initialBalance = address(this).balance;

        if (contractTokenBalance >= minTokenNumberUpperlimit &&
            initialBalance <= rewardHardcap &&
            swapAndLiquifyEnabled &&
            from != pancakePair &&
            !(from == address(this) && to == address(pancakePair))
            ) {             
                Utils.swapTokensForEth(address(pancakeRouter), minTokenNumberToSell);       
                uint256 deltaBalance = address(this).balance.sub(initialBalance);

                if (tokenomics.marketing > 0) {
                    // send marketing rewards
                    (bool sent, ) = payable(address(marketingwallet)).call{value: deltaBalance.mul(tokenomics.marketing).div(_Tokenomics)}("");
                    require(sent, "Error: Cannot send reward");
                }

                if (tokenomics.reserve > 0) {
                    // send resere rewards
                    (bool succ, ) = payable(address(reservewallet)).call{value: deltaBalance.mul(tokenomics.reserve).div(_Tokenomics)}("");
                    require(succ, "Error: Cannot send reward");
                }   

                if (tokenomics.liquidity > 0) {
                    // add liquidity to pancake
                    uint256 liquidityToken = minTokenNumberToSell.mul(tokenomics.liquidity).div(_Tokenomics);
                    Utils.addLiquidity(
                        address(pancakeRouter),
                        owner(),
                        liquidityToken,
                        deltaBalance.mul(tokenomics.liquidity).div(_Tokenomics)
                    ); 
                    emit SwapAndLiquify(liquidityToken, deltaBalance, liquidityToken);
                }          
            }
    }

    function triggerSwapAndLiquify() public lockTheSwap {
        require(((_msgSender() == address(triggerwallet)) || (_msgSender() == owner())) && swapAndLiquifyEnabled, "Wrong caller or swapAndLiquify not enabled");

        uint256 initialBalance = address(this).balance;

        //check triggerwallet balance
        if (address(triggerwallet).balance < 0.1 ether && initialBalance > 0.1 ether) {
            (bool sent, ) = payable(address(triggerwallet)).call{value: 0.1 ether}("");
            require(sent, "Error: Cannot send gas fee");
            initialBalance = address(this).balance;
        }

        Utils.swapTokensForEth(address(pancakeRouter), minTokenNumberToSell);       
        uint256 deltaBalance = address(this).balance.sub(initialBalance);

        if (tokenomics.marketing > 0) {
            // send marketing rewards
            (bool sentm, ) = payable(address(marketingwallet)).call{value: deltaBalance.mul(tokenomics.marketing).div(_Tokenomics)}("");
            require(sentm, "Error: Cannot send reward");
        }

        if (tokenomics.reserve > 0) {
            // send resere rewards
            (bool sentr, ) = payable(address(reservewallet)).call{value: deltaBalance.mul(tokenomics.reserve).div(_Tokenomics)}("");
            require(sentr, "Error: Cannot send reward");
        }

        if (tokenomics.liquidity > 0) {
            // add liquidity to pancake
            uint256 liquidityToken = minTokenNumberToSell.mul(tokenomics.liquidity).div(_Tokenomics);
            Utils.addLiquidity(
                address(pancakeRouter),
                owner(),
                liquidityToken,
                deltaBalance.mul(tokenomics.liquidity).div(_Tokenomics)
            ); 
            emit SwapAndLiquify(liquidityToken, deltaBalance, liquidityToken);
        }
    }

    function changerewardCycleBlock(uint256 newcycle) public onlyOwner {
        rewardCycleBlock = newcycle;
    }

    function changereservewallet(address payable _newaddress) public onlyOwner {
        reservewallet = _newaddress;
    }

    function changemarketingwallet(address payable _newaddress) public onlyOwner {
        marketingwallet = _newaddress;
    }

    function changetriggerwallet(address payable _newaddress) public onlyOwner {
        triggerwallet = _newaddress;
    }

    // disable enable reflection fee , value == false (enable)
    function reflectionfeestartstop(bool _value) public onlyOwner {
        reflectionFeesDisabled = _value;
    }

    function migrateToken(address _newadress, uint256 _amount) public onlyOwner{
        removeAllFee();
        _transferStandard(address(this), _newadress, _amount);
        restoreAllFee();
    }

    function migrateWBnb(address _newadress, uint256 _amount) public onlyOwner {
        IWBNB(payable(address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c))).transfer(_newadress,_amount);
    }

    function migrateBnb(address payable _newadd, uint256 amount) public onlyOwner{
        (bool success, ) = address(_newadd).call{value: amount}("");
        require(success, "Address: unable to send value, charity may have reverted");
    }

    function changeThreshHoldTopUpRate(uint256 _newrate) public onlyOwner {
        threshHoldTopUpRate = _newrate;
    }

    function changeSelltax(uint256 _selltax) public onlyOwner {
        selltax = _selltax;  
    }

    function changeBuytax(uint256 _buytax) public onlyOwner {
        buytax = _buytax;
    }

    function changeTransfertax(uint256 _transfertax) public onlyOwner {
        transfertax = _transfertax;
    }

    function changeTokenomics(uint256 bnbReward, uint256 liquidity, uint256 marketing, uint256 reflection, uint256 reserve) public onlyOwner {
        require(bnbReward + liquidity + marketing + reflection + reserve == 100, "Have to be 100 in total");
        tokenomics = Tokenomics(bnbReward, liquidity, marketing, reflection, reserve);
        updateTokenomics();
    }

    function changebnbclaimtax(uint256 _layer1, uint256 _layer2, uint256 _layer3, uint256 _layer4, uint256 _layer5, uint256 _layer6) public onlyOwner {
        bnbClaimTax = LayerTax(_layer1, _layer2, _layer3, _layer4, _layer5, _layer6);
    }           

    /*
    function changereinvesttax(uint256 _layer1, uint256 _layer2, uint256 _layer3, uint256 _layer4, uint256 _layer5, uint256 _layer6) public onlyOwner {
        reinvestTax = LayerTax(_layer1, _layer2, _layer3, _layer4, _layer5, _layer6);
    }
    */

    function changeminTokenNumberToSell(uint256 _newvalue) public onlyOwner {
        require(_newvalue <= minTokenNumberUpperlimit, "Incorrect Value");
        minTokenNumberToSell = _newvalue;
    }

    function changeminTokenNumberUpperlimit(uint256 _newvalue) public onlyOwner {
        require(_newvalue >= minTokenNumberToSell, "Incorrect Value");
        minTokenNumberUpperlimit = _newvalue;
    }

    function changerewardHardcap(uint256 _newvalue) public onlyOwner {
        rewardHardcap = _newvalue;
    }

    function updateTokenomics() private {
        _Reflection = tokenomics.reflection;
        _Tokenomics = tokenomics.bnbReward.add
                      (tokenomics.marketing).add
                      (tokenomics.liquidity).add
                      (tokenomics.reserve);
    }

    function updatePairAddress(address _pairAddress, bool _enable) public onlyOwner {
        require(pairAddresses[_pairAddress] != _enable, "Will have no effect..");
        pairAddresses[_pairAddress] = _enable;
    }

    /*
    function initializeUpgradedContract() public onlyOwner {
        
    }
    */

    function changeclaimBNBLimit(uint256 _newvalue) public onlyOwner {
        claimBNBLimit = _newvalue;
    }

    function changereinvestLimit(uint256 _newvalue) public onlyOwner {
        reinvestLimit = _newvalue;
    }

    function changeHODLMasterChef(address _newaddress) public onlyOwner {
        HodlMasterChef = _newaddress;
    }

    function changeAntiFlipTax(uint256 _value, uint8 _layer) public onlyOwner {
        require(_value >= 0 && _value <= 1000, "Error: value");
        require(_layer >= 0 && _layer <= 5, "Error: layer");
        antiFlipTax[_layer] = _value;
    }

    function changeStackingWallet(address payable _newaddress) public onlyOwner {
        stackingWallet = _newaddress;
    }

    function getStackingCounter(uint64 cycle) public view returns (uint64) {
        return uint64((block.timestamp-stackingCounterStart) / cycle);
    }

    function enableStacking(bool _value) public onlyOwner {
        stackingEnabled = _value;
    }

    function changeBNBstackingLimit(uint256 _newvalue) public onlyOwner {
        bnbStackingLimit = _newvalue;
    }

    function startStacking() public {
        
        uint96 balance = uint96(balanceOf(msg.sender)-1E9);

        require(stackingEnabled && !rewardStacking[msg.sender].enabled, "Not available");
        require(nextAvailableClaimDate[msg.sender] <= block.timestamp, "Error: next available not reached");
        require(balance > 0, "Error: Wrong amount");
        require(calculateBNBReward(msg.sender) < bnbStackingLimit, "Reward too high");

        rewardStacking[msg.sender] = stacking(true, uint64(rewardCycleBlock), uint64(block.timestamp), getStackingCounter(uint64(rewardCycleBlock)), uint96(bnbStackingLimit), uint96(balance), uint96(rewardHardcap));
        _tokenTransfer(msg.sender, stackingWallet, balance, false);
    }

    function getStacked(address _address) public view returns (uint256) {
        uint256 reward;
        stacking memory tmpStack =  rewardStacking[_address];

        if (tmpStack.enabled) {
            uint256 stackedThousends = (block.timestamp-stackingCounterStart).mul(1000) / tmpStack.cycle - (tmpStack.stackingCounter*1000);
            uint256 stacked = stackedThousends.div(1000);
            uint256 rest = stackedThousends-stacked.mul(1000);
            uint256 totalsupply = uint256(_tTotal)
                .sub(balanceOf(address(0)))
                .sub(balanceOf(0x000000000000000000000000000000000000dEaD)) // exclude burned wallet
                .sub(balanceOf(address(pancakePair))); // exclude liquidity wallet
            uint256 initialBalance = address(this).balance;
            
            
            if (initialBalance >= tmpStack.hardcap)
            {
                reward = uint256(tmpStack.hardcap) * tmpStack.amount / totalsupply * stackedThousends / 1000;
                if (initialBalance.sub(reward) < tmpStack.hardcap)
                {
                    reward = 0;
                    if (stacked > 0) reward = initialBalance - Utils.calcReward(initialBalance, totalsupply / tmpStack.amount, stacked, 10);   //address(this).balance - address(this).balance.mul(1-(rewardStacking[_address].amount.div(totalsupply))**stacked);
                    reward += initialBalance.sub(reward) * tmpStack.amount / totalsupply * rest / 1000;
                }
            } else {
                if (stacked > 0) reward = initialBalance - Utils.calcReward(initialBalance, totalsupply / tmpStack.amount, stacked, 10); 
                reward += initialBalance.sub(reward) * tmpStack.amount / totalsupply * rest / 1000;
            }

        }
        return reward > tmpStack.stackingLimit ? uint256(tmpStack.stackingLimit) : reward;
    }

    function stopStackingAndClaim(uint256 perc) public nonReentrant {
        require(rewardStacking[msg.sender].enabled, "Stacking not enabled");

        uint256 rewardBNB;
        uint256 rewardreinvest;
        uint256 reward = getStacked(msg.sender);

        if (perc == 100) {
            rewardBNB = reward;
        } else if (perc == 0) {     
            rewardreinvest = reward;
        } else {
            rewardBNB = reward.mul(perc).div(100);
            rewardreinvest = reward.sub(rewardBNB);
        }

        // BNB REINVEST
        if (perc < 100) {

            // Re-InvestTokens
            uint256 expectedtoken = Utils.getAmountsout(rewardreinvest, address(pancakeRouter));

            // update reinvest rewards
            userreinvested[msg.sender] += expectedtoken;
            totalreinvested += expectedtoken;
            _tokenTransfer(address(this), msg.sender, expectedtoken, false);

        }

        // BNB CLAIM
        if (rewardBNB > 0) {
            uint256 rewardfee;
            bool success;
            // deduct tax
            if (rewardBNB < 0.1 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer1).div(100);
            } else if (rewardBNB < 0.25 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer2).div(100);
            } else if (rewardBNB < 0.5 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer3).div(100);
            } else if (rewardBNB < 0.75 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer4).div(100);
            } else if (rewardBNB < 1 ether) {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer5).div(100);
            } else {
                rewardfee = rewardBNB.mul(bnbClaimTax.layer6).div(100);
            }
            rewardBNB -= rewardfee;
            (success, ) = address(reservewallet).call{value: rewardfee}("");
            require(success, " Error: Cannot send reward");

            // send bnb to user
            (success, ) = address(msg.sender).call{value: rewardBNB}("");
            require(success, "Error: Cannot withdraw reward");

            // update claimed rewards
            userClaimedBNB[msg.sender] += rewardBNB;
            totalClaimedBNB += rewardBNB;
        }

        _tokenTransfer(stackingWallet, msg.sender, rewardStacking[msg.sender].amount, false);

        stacking memory tmpStack;
        rewardStacking[msg.sender] = tmpStack;

        // update rewardCycleBlock
        nextAvailableClaimDate[msg.sender] = block.timestamp + rewardCycleBlock;
        emit ClaimBNBSuccessfully(msg.sender,reward,nextAvailableClaimDate[msg.sender]);
    }
    
    function TestAddLiquidityWithoutTax(uint256 _token) public payable {
        
        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();

        //uint256[] memory amounts = pancakeRouter.getAmountsOut(_token, path);
        
        _tokenTransfer(msg.sender, pancakePair, _token, false);
        // IWETH(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd).deposit{value: pancakeRouter.getAmountsOut(_token, path)[1]}();
        //payable(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd).call{value: amounts[1]}("");
        //assert(IWETH(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd).transfer(pancakePair, amounts[1]));
        IPancakePair(pancakePair).mint(msg.sender);
        /*
        if (msg.value > amounts[1]) {
            //(success, ) = address(reservewallet).call{value: rewardfee}("");
            (bool success, ) = address(msg.sender).call{value: msg.value - amounts[1]}("");
            require(success, "Err");
        }
        */
       // safeTransferETH(msg.sender, ); // refund dust eth, if any

    }

}