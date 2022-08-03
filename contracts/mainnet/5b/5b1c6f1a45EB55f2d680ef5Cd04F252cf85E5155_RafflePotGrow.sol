// SPDX-License-Identifier: MIT

import "./IterableMapping.sol";
import "./Utils.sol";

pragma solidity ^0.8.4;

contract RafflePotGrow is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    using Address for address;
    
    uint randNonce = 0;
    string private _name = "RafflePotGrow";
    string private _symbol = "RPG";
    uint8 private _decimals = 9;

    address payable public marketingWalletAddress = payable(0x5b516572aFF1b984d01925e2Ed37633E45c8d54F);
    address payable public teamWalletAddress = payable(0xBfc2CEd48FD1365aC0ACbD637045b1F67B3E330D);
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    using IterableMapping for IterableMapping.Map;
    IterableMapping.Map private lotteryParticipants;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isMarketPair;


    uint256 public _buyLiquidityFee = 2;
    uint256 public _buyMarketingFee = 5;
    uint256 public _buyJackPotFee = 5;
    uint256 public _buyTeamFee = 0;
    
    uint256 public _sellLiquidityFee = 4;
    uint256 public _sellMarketingFee = 4;
    uint256 public _sellJackPotFee = 5;
    uint256 public _sellTeamFee = 1;

    uint256 public _liquidityShare = 15;
    uint256 public _marketingShare = 25;
    uint256 public _teamShare = 25;
    uint256 public _JackPotShare = 35;

    uint256 public _totalTaxIfBuying = 12;
    uint256 public _totalTaxIfSelling = 13;
    uint256 public _totalDistributionShares = 100;

    uint256 public _totalSupply =  1000000000 * 10**_decimals;    
    uint256 public _walletMax =     15000000 * 10**_decimals;      
    uint256 public minimumTokensBeforeSwap = 5000000 * 10**_decimals; 

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyByLimitOnly = false;
    bool public checkWalletLimit = true;

    uint256 public lotteryBalance=0;
    uint256 public lotteryBalanceLimit=0.001 * 10**18;
    uint256 public tokenAmountForLotteryParticipant = 1 * 10**_decimals; 

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );

    event inSwapAndLiquifyStatus(bool p);
    event stepLiquify(bool overMinimumTokenBalanceStatus,bool inSwapAndLiquifyStatus, bool isMarketPair_sender, bool swapAndLiquifyEnabledStatus);
    event stepFee(bool p);

    event teamGetBnb(uint256 amount);
    event marketingGetBnb(uint256 amount);
    event liquidityGetBnb(uint256 amount);
    event eventSwapAndLiquify(uint256 amount);
    event winnerIs(address winner,uint256 amountBNB);
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {
        //CHANGE IN PROD
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        //T 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 P 0x10ED43C718714eb63d5aA57B78B54704E256024E
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;

        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
        
        _totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee).add(_buyTeamFee).add(_buyJackPotFee);
        _totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee).add(_sellTeamFee).add(_sellJackPotFee);
        _totalDistributionShares = _liquidityShare.add(_marketingShare).add(_teamShare).add(_JackPotShare);
        
        isMarketPair[address(uniswapPair)] = true;

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

    function setMarketPairStatus(address account, bool newValue) public onlyOwner {
        isMarketPair[account] = newValue;
    }

    function setLotteryBalanceLimit(uint256 amount) public onlyOwner {
        lotteryBalanceLimit=amount;
    }

    
    function setIsExcludedFromFee(address account, bool newValue) public onlyOwner {
        isExcludedFromFee[account] = newValue;
    }

    function excludeLotteryPartecipant(address account)public onlyOwner{
        lotteryParticipants.remove(account);
    }

    function setTokenAmountForLotteryParticipant(uint256 amount) external onlyOwner {
        tokenAmountForLotteryParticipant = amount * 10**_decimals;
    }

    function setBuyTaxes(uint256 newLiquidityTax, uint256 newMarketingTax, uint256 newTeamTax,uint256 newJackPotTax) external onlyOwner() {
         require(newLiquidityTax.add(newMarketingTax).add(newTeamTax).add(newJackPotTax) <= 12, "Tax exceeds the 12%.");
        _buyLiquidityFee = newLiquidityTax;
        _buyMarketingFee = newMarketingTax;
        _buyTeamFee = newTeamTax;
        _buyJackPotFee=newJackPotTax;

        _totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee).add(_buyTeamFee).add(_buyJackPotFee);
    }

    function setSelTaxes(uint256 newLiquidityTax, uint256 newMarketingTax, uint256 newTeamTax,uint256 newJackPotTax) external onlyOwner() {
        require(newLiquidityTax.add(newMarketingTax).add(newTeamTax).add(newJackPotTax) <= 13, "Tax exceeds the 13%.");
        _sellLiquidityFee = newLiquidityTax;
        _sellMarketingFee = newMarketingTax;
        _sellTeamFee = newTeamTax;
        _sellJackPotFee=newJackPotTax;

        _totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee).add(_sellTeamFee).add(_sellJackPotFee);
    }
    
    function setDistributionSettings(uint256 newLiquidityShare, uint256 newMarketingShare, uint256 newTeamShare,uint256 newJackPotShare) external onlyOwner() {
        _liquidityShare = newLiquidityShare;
        _marketingShare = newMarketingShare;
        _teamShare = newTeamShare;
        _JackPotShare=newJackPotShare;
        _totalDistributionShares = _liquidityShare.add(_marketingShare).add(_teamShare).add(newJackPotShare);
    }
    
    function enableDisableWalletLimit(bool newValue) external onlyOwner {
       checkWalletLimit = newValue;
    }


    function setWalletLimit(uint256 newLimit) external onlyOwner {
        require(newLimit >= 15000000, "Max Wallet min 15000000.");
        _walletMax  = newLimit;
    }

    function setNumTokensBeforeSwap(uint256 newLimit) external onlyOwner() {
        minimumTokensBeforeSwap = newLimit;
    }

    function setMarketingWalletAddress(address newAddress) external onlyOwner() {
        marketingWalletAddress = payable(newAddress);
    }

    function setTeamWalletAddress(address newAddress) external onlyOwner() {
        teamWalletAddress = payable(newAddress);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setSwapAndLiquifyByLimitOnly(bool newValue) public onlyOwner {
        swapAndLiquifyByLimitOnly = newValue;
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }
    
    function changeRouterVersion(address newRouterAddress) public onlyOwner returns(address newPairAddress) {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(newRouterAddress); 

        newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(address(this), _uniswapV2Router.WETH());

        if(newPairAddress == address(0)) 
        {
            newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());
        }

        uniswapPair = newPairAddress; 
        uniswapV2Router = _uniswapV2Router; 

        isMarketPair[address(uniswapPair)] = true;
    }

    function isPartecipant(address account) public view returns(bool){
        
        return lotteryParticipants.getIndexOfKey(account) >=0 && lotteryParticipants.get(account) >= tokenAmountForLotteryParticipant ? true : false;
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

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if(inSwapAndLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {           

            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;
            emit stepLiquify(overMinimumTokenBalance,!inSwapAndLiquify,!isMarketPair[sender],swapAndLiquifyEnabled);
            if (overMinimumTokenBalance && !inSwapAndLiquify && !isMarketPair[sender] && swapAndLiquifyEnabled) 
            {
                if(swapAndLiquifyByLimitOnly)
                    contractTokenBalance = minimumTokensBeforeSwap;
                swapAndLiquify(contractTokenBalance);    
            }

            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

            uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) ? 
                                         amount : takeFee(sender, recipient, amount);

            if(checkWalletLimit && !isMarketPair[recipient] && recipient != owner())
                require(balanceOf(recipient).add(finalAmount) <= _walletMax);

            _balances[recipient] = _balances[recipient].add(finalAmount);
            updatePartecipant(sender,recipient);
            emit Transfer(sender, recipient, finalAmount);
            return true;
        }
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapAndLiquify(uint256 tAmount) private lockTheSwap {
        
        uint256 tokensForLP = tAmount.mul(_liquidityShare).div(_totalDistributionShares).div(2);
        uint256 tokensForSwap = tAmount.sub(tokensForLP);

        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance.sub(lotteryBalance);

        emit eventSwapAndLiquify(amountReceived);

        uint256 totalBNBFee = _totalDistributionShares.sub(_liquidityShare.div(2));
        
        uint256 amountBNBLiquidity = amountReceived.mul(_liquidityShare).div(totalBNBFee).div(2);
        uint256 amountBNBTeam = amountReceived.mul(_teamShare).div(totalBNBFee);
        uint256 amountJackPot = amountReceived.mul(_JackPotShare).div(totalBNBFee);
        uint256 amountBNBMarketing = amountReceived.sub(amountBNBLiquidity).sub(amountBNBTeam).sub(amountJackPot);

        emit teamGetBnb(amountBNBTeam);
        emit marketingGetBnb(amountBNBMarketing);
        emit liquidityGetBnb(amountBNBLiquidity);

        if(amountBNBMarketing > 0)
            transferToAddressETH(marketingWalletAddress, amountBNBMarketing);

        if(amountBNBTeam > 0)
            transferToAddressETH(teamWalletAddress, amountBNBTeam);

        if(amountBNBLiquidity > 0 && tokensForLP > 0)
            addLiquidity(tokensForLP, amountBNBLiquidity);

        if(amountJackPot > 0)
            lotteryBalance = lotteryBalance.add(amountJackPot);
    }
    
    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this), 
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            owner(),
            block.timestamp
        );
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = 0;
        
        if(isMarketPair[sender]) {
            feeAmount = amount.mul(_totalTaxIfBuying).div(100); 
        }
        else if(isMarketPair[recipient]) {
            feeAmount = amount.mul(_totalTaxIfSelling).div(100);
        }
        
        if(feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount);
    }

    function updatePartecipant(address sender, address recipient)internal{
        if(isMarketPair[sender]) {
            if(_balances[recipient] >= tokenAmountForLotteryParticipant)
                lotteryParticipants.set(recipient,_balances[recipient]);
        }
        else if(isMarketPair[recipient]) {
            if(_balances[sender] < tokenAmountForLotteryParticipant && lotteryParticipants.getIndexOfKey(sender) >= 0)
                lotteryParticipants.remove(sender);
        }else{

            if(_balances[recipient]< tokenAmountForLotteryParticipant && lotteryParticipants.getIndexOfKey(recipient) >= 0)
                lotteryParticipants.remove(recipient);

            if(_balances[sender] < tokenAmountForLotteryParticipant && lotteryParticipants.getIndexOfKey(sender) >= 0)  
                lotteryParticipants.remove(sender);  
        }
    }

    function lotteryDraw() public onlyOwner{
        randNonce++;
        uint256 amountJackpot = address(this).balance;
        
        require(amountJackpot >= lotteryBalanceLimit, "Insufficient jackpot");

        if(amountJackpot > lotteryBalanceLimit)
            amountJackpot = amountJackpot.sub(amountJackpot.sub(lotteryBalanceLimit));

        uint256 partecipantWinner = uint256(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % lotteryParticipants.keys.length;
        bool winnerAvailable = false;

        for(uint256 i= 0;i<lotteryParticipants.keys.length;i++){
            if(lotteryParticipants.get(lotteryParticipants.keys[i])>=tokenAmountForLotteryParticipant){
                winnerAvailable=true;
            }
        }

        require(winnerAvailable,"No lottery participant present among the holders.");

        while(lotteryParticipants.get(lotteryParticipants.keys[partecipantWinner])<tokenAmountForLotteryParticipant)
            partecipantWinner = uint256(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % lotteryParticipants.keys.length;

        address payable winner= payable(lotteryParticipants.keys[partecipantWinner]);
        transferToAddressETH(winner, amountJackpot);
        lotteryBalance=lotteryBalance.sub(amountJackpot);
        emit winnerIs(winner,amountJackpot);
    }

    function recoveryJackpot() public onlyOwner{
        lotteryBalance=0;
        uint256 amountJackpot = address(this).balance;
        address payable ownerWallet = payable(owner());
        transferToAddressETH(ownerWallet, amountJackpot);
    }

  }