// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./ERC20.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
import "./SafeMath.sol";
import "./BokkyPooBahsDateTimeLibrary.sol";

contract Maxim is ERC20 {
    using SafeMath for uint256;
    using BokkyPooBahsDateTimeLibrary for uint;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;    
    address _tokenOwner;
    IERC20 public pair;

    address uniswapV2RouterAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address usdtAddress = address(0x55d398326f99059fF775485246999027B3197955);
    address deadAddress = address(0x000000000000000000000000000000000000dEaD);
    address zeroAddress = address(0x0000000000000000000000000000000000000000);

    address fundAddress = address(0xCf3B0Bb8ce426086A6E95f98615B2Be2F5e915E6);
    address blindBoxFundAddress = address(0xe2860b70cC74bdD61b7C0edc15C61919007A2c05);
    address wrapAddress = address(0xCf3B0Bb8ce426086A6E95f98615B2Be2F5e915E6);

    address[] shareholders;
    struct Share {
        bool exists;
        bool enabled;
        uint256 fee;
    }

    mapping(address => Share) shares;

    address[] supplyLpUsers;
    struct LPHolder {
        address account;
        bool enabled;
        uint256 amount;
        uint startTime;
        uint lockTime;
        uint releaseDatetime;
        uint256 releaseRatio;
        uint256 releaseAmount;
    }
    mapping(uint256 => LPHolder) LPHolders;
    uint256 lockLPHolderAmount;

    uint256 tenThousand = 10000;
    uint256 buyFundFee = 800;
    uint256 sellFundFee = 800;
    uint256 blindBoxFundFee = 2500;
    uint256 shareholderFundFee = 7500;

    struct blindBoxFundDaily {
        uint256 mt;
        uint256 ut;
        uint256 st;
    }
    mapping(uint => blindBoxFundDaily) private _blindBoxFundDailyIncome;
    mapping(address => bool) private _isFeeExempt;
    mapping(address => bool) private _isVipExempt;
    mapping(address => bool) private _isTxLimitExempt;
    mapping(address => bool) private _isBuyTokenExempt;

    bool isCanTx;

    uint256 _tTotal = 10000 * (10 ** decimals());
    mapping(address => bool) public automatedMarketMakerPairs;

    uint256 public maxTxAmount = 5 * (10 ** decimals());
    uint256 public swapTokensAtAmount;
    bool public swapEnabled = true;
    bool inSwap;
    modifier lockTheSwap() { inSwap = true; _; inSwap = false; }    

    uint256 public launchedAt;
    IERC20 public USDT;    

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event FeeExempt(address indexed account, bool isExempted);
    event FeeMultipleAccountsExempt(address[] accounts, bool isExempted);
    event VipExempt(address indexed account, bool isExempted);
    event BuyTokenExempt(address indexed account, bool isExempted);
    event AddLpLock(address indexed account, uint256 index, uint256 amount, bool enabled, uint lockTime, uint256 releaseRatio);
    event ReleaseLpLock(address indexed account, uint256 releaseTotalAmount, uint256 releaseAmount, uint256 releaseDate);
    event BlindBoxFundChanged(uint date, uint256 amount, uint256 totalAmount);
    event BuyToken(address indexed account, uint256 amount);

    constructor(address tokenOwner) ERC20("Maxim", "Maxim") {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(uniswapV2RouterAddress);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), usdtAddress);   
        _approve(address(this), uniswapV2RouterAddress, _tTotal.mul(100000));
        USDT = IERC20(usdtAddress);
        USDT.approve(uniswapV2RouterAddress, _tTotal.mul(100000));
        pair = IERC20(_uniswapV2Pair);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;             
        _tokenOwner = tokenOwner;
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);
        _isFeeExempt[tokenOwner] = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[_owner] = true;
        _isFeeExempt[fundAddress] = true;
        _isFeeExempt[blindBoxFundAddress] = true;

        _isTxLimitExempt[_owner] = true;
        _isTxLimitExempt[tokenOwner] = true;

        _isVipExempt[tokenOwner] = true;
        _isVipExempt[address(this)] = true;
        _isVipExempt[_owner] = true;
        
        swapTokensAtAmount = 10 ** 17;
        lockLPHolderAmount = 0;
        _mint(tokenOwner, _tTotal);
    }

    receive() external payable { }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function setSwapBackSetting(bool _enabled, uint256 _swapTokensAtAmount) public onlyOwner {
        swapEnabled = _enabled;
        swapTokensAtAmount = _swapTokensAtAmount;
    }

    function setCanTx(bool _isCanTx) public onlyOwner {
        isCanTx = _isCanTx;
    }

    function feeExempt(address account, bool exempted) public onlyOwner {
        _isFeeExempt[account] = exempted;
        emit FeeExempt(account, exempted);
    }

    function vipExempt(address account, bool exempted) public onlyOwner {
        _isVipExempt[account] = exempted;
        emit VipExempt(account, exempted);
    }  

    function buyTokenExempt(address account, bool exempted) public onlyOwner {
        _isBuyTokenExempt[account] = exempted;
        emit BuyTokenExempt(account, exempted);
    }       
	
    function feeMultipleAccountsExempt(address[] calldata accounts, bool exempted) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isFeeExempt[accounts[i]] = exempted;
        }
        emit FeeMultipleAccountsExempt(accounts, exempted);
    }

    function setMaxTxAmount(uint256 _maxTxAmount) public onlyOwner {
        maxTxAmount = _maxTxAmount;
    }  

    function setShareholder(address shareholder, bool enabled, uint256 fee) public onlyOwner {
        if(enabled){
            _addShareholder(shareholder, fee);
        } else {
            _removeShareholder(shareholder);
        }
    }    

    function setFee(uint256 _buyFundFee, uint256 _sellFundFee, uint256 _blindBoxFundFee, uint256 _shareholderFundFee) public onlyOwner {
        buyFundFee = _buyFundFee < tenThousand ? _buyFundFee : buyFundFee;
        sellFundFee = _sellFundFee < tenThousand ? _sellFundFee : sellFundFee;
        blindBoxFundFee = _blindBoxFundFee < tenThousand ? _blindBoxFundFee : blindBoxFundFee;
        shareholderFundFee = _shareholderFundFee < tenThousand ? _shareholderFundFee : shareholderFundFee;
    }

    function setIsTxLimitExempt(address account, bool exempted) external onlyOwner {
        _isTxLimitExempt[account] = exempted;
    }

    function rescueToken(address tokenAddress, uint256 tokens) public onlyOwner returns (bool) {
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    function updateSwapWrap(address _wrapAddress) public onlyOwner {
        wrapAddress = _wrapAddress;
    }

    function addLpLock(address account, uint256 amount, bool enabled, uint lockTime, uint256 releaseRatio) public onlyOwner returns (uint256) {
        uint256 index = supplyLpUsers.length;
        if(amount > 0 && releaseRatio < tenThousand){
            supplyLpUsers.push(account);
            LPHolders[index].account = account;
            LPHolders[index].enabled = enabled;
            LPHolders[index].amount = amount;
            LPHolders[index].startTime = block.timestamp;
            LPHolders[index].lockTime = lockTime;
            LPHolders[index].releaseRatio = releaseRatio;
            lockLPHolderAmount = lockLPHolderAmount.add(amount);
            emit AddLpLock(account, index, amount, enabled, lockTime, releaseRatio);
        }
        return index;
    }

    function revokeLpLock(uint256 index) public onlyOwner returns (bool) {
        bool enabled = false;
        if(LPHolders[index].startTime > 0 && LPHolders[index].enabled != enabled){
            LPHolders[index].enabled = enabled;
            uint256 _amount = LPHolders[index].amount.sub(LPHolders[index].releaseAmount);
            lockLPHolderAmount = lockLPHolderAmount.sub(_amount);
        } else {
            return false;
        }
        return true;
    }

    function releaseLpLock() public {
        uint _timestamp = block.timestamp;
        (uint year, uint month, uint day) = BokkyPooBahsDateTimeLibrary.timestampToDate(_timestamp);
        uint today = BokkyPooBahsDateTimeLibrary.timestampFromDate(year, month, day);  
        uint256 usdtBalance = USDT.balanceOf(address(this));
        require(usdtBalance > 0, "Balance Not Enough");
        uint256 releaseTotalAmount = 0;    
        for(uint256 i = 0; i < supplyLpUsers.length; i++){
            require(usdtBalance >= releaseTotalAmount, "Balance Not Enough");
            address suppler = supplyLpUsers[i];
            if(!LPHolders[i].enabled){
                continue;
            }
            if(LPHolders[i].releaseAmount >= LPHolders[i].amount){
                LPHolders[i].enabled = false;
                continue;
            }
            if(LPHolders[i].startTime + LPHolders[i].lockTime > _timestamp){
                continue;
            }
            if(LPHolders[i].releaseDatetime == today){
                continue;
            }
            uint256 _releaseAmount = LPHolders[i].amount.div(tenThousand).mul(LPHolders[i].releaseRatio);
            bool isSuccess = true;
            try USDT.transfer(suppler,_releaseAmount) {} catch {
                isSuccess = false;
            }
            if(isSuccess){
                releaseTotalAmount = releaseTotalAmount.add(_releaseAmount);
                LPHolders[i].releaseAmount = LPHolders[i].releaseAmount.add(_releaseAmount);
                LPHolders[i].releaseDatetime = today;
                lockLPHolderAmount = lockLPHolderAmount.sub(_releaseAmount);
                emit ReleaseLpLock(LPHolders[i].account, LPHolders[i].releaseAmount, _releaseAmount, today);
            }
        }
    }    

    function buyToken(uint256 _amount, address _to) public lockTheSwap returns (uint256) {
        address from = msg.sender;
        require(_isBuyTokenExempt[from], "Buy Token Limit Exceeded");
        require(_amount > 0, "Buy Amount Must Be Greater Than Zero");
        USDT.transferFrom(from, address(this), _amount);
        uint256 beforeBalance = balanceOf(_to); 
        _swapTokensToMoin(_amount, _to);
        uint256 afterBalance = balanceOf(_to); 
        uint256 increaseBalance = afterBalance.sub(beforeBalance);
        emit BuyToken(_to, increaseBalance);
        return increaseBalance;
    }

    function swapBlindBoxFund(uint timestamp) public lockTheSwap returns (uint256 mt, uint256 st, uint256 ut) {
        address from = msg.sender;
        require(_isBuyTokenExempt[from], "Swap Token Limit Exceeded"); 
        uint256 canSwap = _blindBoxFundDailyIncome[timestamp].mt.sub(_blindBoxFundDailyIncome[timestamp].st);
        if(canSwap > 0){
            super._transfer(blindBoxFundAddress, address(this), canSwap);
            uint256 beforeUsdtBalance = USDT.balanceOf(blindBoxFundAddress);
            _swapTokensToUsdt(canSwap, blindBoxFundAddress);
            uint256 afterUsdtBalance = USDT.balanceOf(blindBoxFundAddress);
            uint256 blindBoxFeeUsdtAmount = afterUsdtBalance.sub(beforeUsdtBalance);
            _blindBoxFundDailyIncome[timestamp].ut = _blindBoxFundDailyIncome[timestamp].ut > 0 ? _blindBoxFundDailyIncome[timestamp].ut.add(blindBoxFeeUsdtAmount) : blindBoxFeeUsdtAmount;
            _blindBoxFundDailyIncome[timestamp].st = _blindBoxFundDailyIncome[timestamp].st > 0 ? _blindBoxFundDailyIncome[timestamp].st.add(canSwap) : canSwap;
        }
        return (_blindBoxFundDailyIncome[timestamp].mt, _blindBoxFundDailyIncome[timestamp].st, _blindBoxFundDailyIncome[timestamp].ut);
    }

    function readBlindBoxFundDailyIncome(uint timestamp) public view returns (uint256 mt, uint256 st, uint256 ut) {
        return (_blindBoxFundDailyIncome[timestamp].mt, _blindBoxFundDailyIncome[timestamp].st, _blindBoxFundDailyIncome[timestamp].ut);
    }    

    function isShareholder(address shareholder) public view returns (bool) {
        return shares[shareholder].enabled;
    }

    function isFeeExempt(address account) public view returns (bool) {
        return _isFeeExempt[account];
    }

    function isVipExempt(address account) public view returns (bool) {
        return _isVipExempt[account];
    }    

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

		if(from == address(this) || to == address(this)){
            super._transfer(from, to, amount);
            return;
        }

        checkTxLimit(from, to, amount);
        

        if(shouldSwapBack()){ swapBack(); }

        if(!launched() && automatedMarketMakerPairs[to]){ require(balanceOf(from) > 0); launch(); }
        uint256 amountReceived = amount;
        if(shouldTakeTxFee(from, to)) {
            amountReceived = takeTxFee(from, to, amount);
        }

        super._transfer(from, to, amountReceived);      
    }    

    function shouldSwapBack() internal view returns (bool) {
        return !automatedMarketMakerPairs[msg.sender]
        && !inSwap 
        && swapEnabled
        && msg.sender != _tokenOwner
        && balanceOf(address(this)) > swapTokensAtAmount;
    }

    function swapBack() internal lockTheSwap {
        uint256 tokenAmount = balanceOf(address(this));
        if(tokenAmount > 0){
            _swapTokensToUsdt(tokenAmount, wrapAddress);      
        }
        uint256 usdtBalance = USDT.balanceOf(address(this));
        if(usdtBalance > 0 && usdtBalance > lockLPHolderAmount){
            uint256 canAmount = usdtBalance.sub(lockLPHolderAmount);
            USDT.transfer(wrapAddress,canAmount);
        }                    
    }

    function checkTxLimit(address from, address to, uint256 amount) internal view {
        if(block.number > launchedAt + 3){
            require(amount <= maxTxAmount || _isTxLimitExempt[from], "TX Limit Exceeded");
        }
        if(!isCanTx){
            if(automatedMarketMakerPairs[from]){
                require(_isVipExempt[to], "Buy TX Limit Exceeded");
            }else if(automatedMarketMakerPairs[to]){
                require(_isVipExempt[from], "Sell TX Limit Exceeded");
            }            
        }
    }    

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
    }    

    function shouldTakeTxFee(address from, address to) internal view returns (bool) {
        bool takeFee = false;
        if(automatedMarketMakerPairs[from] || automatedMarketMakerPairs[to]){ 
            if(!_isFeeExempt[from] && !_isFeeExempt[to]){
                takeFee = true;
            }            
        }        
        return takeFee;
    }

    function takeTxFee(address from, address to, uint256 amount) internal lockTheSwap returns (uint256) {
        uint256 feeAmount = 0;
        if(automatedMarketMakerPairs[from]){
            feeAmount = amount.div(tenThousand).mul(buyFundFee);
        }else if(automatedMarketMakerPairs[to]){
            feeAmount = amount.div(tenThousand).mul(sellFundFee);
        }
        if(feeAmount > 0){
            uint256 blindBoxFeeAmount = feeAmount.div(tenThousand).mul(blindBoxFundFee);
            super._transfer(from, blindBoxFundAddress, blindBoxFeeAmount);
            _writeBlindBoxFundDailyIncome(blindBoxFeeAmount);

            uint256 shareholderFundFeeAmount = feeAmount.div(tenThousand).mul(shareholderFundFee);
            uint256 shareholderFundFeeAmountActual = 0;
            for(uint256 i = 0; i < shareholders.length; i++){
                address shareholder = shareholders[i];
                if(!isShareholder(shareholder)){
                    continue;
                }
                uint256 _shareholderFundFeeAmount = shareholderFundFeeAmount.div(tenThousand).mul(shares[shareholder].fee);
                shareholderFundFeeAmountActual += _shareholderFundFeeAmount;
                super._transfer(from, shareholder, _shareholderFundFeeAmount);
            }

            uint256 fundFeeAmount = feeAmount.sub(blindBoxFeeAmount).sub(shareholderFundFeeAmountActual);
            if(fundFeeAmount > 0){
                super._transfer(from, fundAddress, fundFeeAmount);
            }
        }
        return amount.sub(feeAmount);
    }

    function _writeBlindBoxFundDailyIncome(uint256 amount) private {
        uint _timestamp = block.timestamp;
        (uint year, uint month, uint day) = BokkyPooBahsDateTimeLibrary.timestampToDate(_timestamp);
        uint today = BokkyPooBahsDateTimeLibrary.timestampFromDate(year, month, day);
        _blindBoxFundDailyIncome[today].mt = _blindBoxFundDailyIncome[today].mt > 0 ? _blindBoxFundDailyIncome[today].mt.add(amount) : amount;
        emit BlindBoxFundChanged(today, amount, _blindBoxFundDailyIncome[today].mt);
    }

    function _addShareholder(address shareholder, uint256 fee) private {
        if(!shares[shareholder].exists){
            shareholders.push(shareholder);
            shares[shareholder].exists = true;
        }
        shares[shareholder].enabled = true;
        shares[shareholder].fee = fee < tenThousand ? fee : 0;        
    }

    function _removeShareholder(address shareholder) private {
        shares[shareholder].enabled = false;
    }   

    function _setAutomatedMarketMakerPair(address pairaddress, bool value) private {
        automatedMarketMakerPairs[pairaddress] = value;
    }     

    function _swapTokensToUsdt(uint _amount, address _to) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdtAddress;
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amount,
            0,
            path,
            _to,
            block.timestamp
        ); 
    }

    function _swapTokensToMoin(uint _amount, address _to) private {
        address[] memory path = new address[](2);
        path[0] = usdtAddress;
        path[1] = address(this);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amount,
            0,
            path,
            _to,
            block.timestamp
        );    
    }    
}