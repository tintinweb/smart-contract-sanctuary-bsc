// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./Utils.sol";

contract ViralUp is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    using Address for address;
    
    string private _name = "VIRALUP";
    string private _symbol = "VIRAL";
    uint8 private _decimals = 18;


    address payable public marketingWalletAddress = payable(0x8B78D8E75753972F771f8b29AB673225C0a32151);
    address payable public nftWalletAddress = payable(0xC1955B4500a3015dc8Daea60870C9a4fA995F964);
    address payable public appWalletAddress = payable(0x31Ec9a8Caaf3ff25E7038BcC8d673eD3aB94b134);
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isMarketPair;

    uint256 public _buyLiquidityFee = 0;
    uint256 public _buyMarketingFee = 2;
    uint256 public _buyNftFee = 1;
    uint256 public _buyAppFee = 0;
    
    uint256 public _sellLiquidityFee = 4;
    uint256 public _sellMarketingFee = 5;
    uint256 public _sellNftFee = 2;
    uint256 public _sellAppFee = 4;

    uint256 public _liquidityShare = 10;
    uint256 public _marketingShare = 45;
    uint256 public _nftShare = 15;
    uint256 public _appShare = 30;

    uint256 public _totalTaxIfBuying = 5;
    uint256 public _totalTaxIfSelling = 15;
    uint256 public _totalDistributionShares = 100;

    uint256 private _totalSupply =  100000000 * 10**_decimals;           
    uint256 private minimumTokensBeforeSwap = 100000 * 10**_decimals; 

    IDEXRouter public idexV2Router;
    address public idexPair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyByLimitOnly = true;

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

    event tokenForNft(uint256 amount);
    event tokenForApp(uint256 amount);
    event marketingGetBnb(uint256 amount);
    event liquidityGetBnb(uint256 amount);
    event eventSwapAndLiquify(uint256 amount);
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {
        //T 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 P 0x10ED43C718714eb63d5aA57B78B54704E256024E
        IDEXRouter _idexV2Router = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        idexPair = IDEXFactory(_idexV2Router.factory())
            .createPair(address(this), _idexV2Router.WETH());

        idexV2Router = _idexV2Router;
        _allowances[address(this)][address(idexV2Router)] = _totalSupply;

        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
        
        _totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee).add(_buyNftFee).add(_buyAppFee);
        _totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee).add(_sellNftFee).add(_sellAppFee);
        _totalDistributionShares = _liquidityShare.add(_marketingShare).add(_nftShare).add(_appShare);

        isMarketPair[address(idexPair)] = true;

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

    
    function setIsExcludedFromFee(address account, bool newValue) public onlyOwner {
        isExcludedFromFee[account] = newValue;
    }


    function setBuyTaxes(uint256 newLiquidityTax, uint256 newMarketingTax, uint256 newNftTax, uint256 newAppTax) external onlyOwner() {
        require(newLiquidityTax.add(newMarketingTax).add(newNftTax).add(newAppTax) <= 18, "Tax exceeds the 18%.");
        _buyLiquidityFee = newLiquidityTax;
        _buyMarketingFee = newMarketingTax;
        _buyNftFee = newNftTax;
        _buyAppFee = newAppTax;

        _totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee).add(_buyNftFee).add(_buyAppFee);
    }

    function setSelTaxes(uint256 newLiquidityTax, uint256 newMarketingTax, uint256 newNftTax, uint256 newAppTax) external onlyOwner() {
        require(newLiquidityTax.add(newMarketingTax).add(newNftTax).add(newAppTax) <= 18, "Tax exceeds the 18%.");
        _sellLiquidityFee = newLiquidityTax;
        _sellMarketingFee = newMarketingTax;
        _sellNftFee = newNftTax;
        _sellAppFee=newAppTax;

        _totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee).add(_sellNftFee).add(_sellAppFee);
    }
    
    function setDistributionSettings(uint256 newLiquidityShare, uint256 newMarketingShare, uint256 newNftShare,uint256 newAppShare) external onlyOwner() {
        _liquidityShare = newLiquidityShare;
        _marketingShare = newMarketingShare;
        _nftShare = newNftShare;
        _appShare=newAppShare;

        _totalDistributionShares = _liquidityShare.add(_marketingShare).add(_nftShare).add(_appShare);
    }

    function setNumTokensBeforeSwap(uint256 newLimit) external onlyOwner() {
        minimumTokensBeforeSwap = newLimit;
    }

    function setMarketingWalletAddress(address newAddress) external onlyOwner() {
        marketingWalletAddress = payable(newAddress);
    }

    function setNftWalletAddress(address newAddress) external onlyOwner() {
        nftWalletAddress = payable(newAddress);
    }

    function setAppWalletAddress(address newAddress) external onlyOwner() {
        appWalletAddress = payable(newAddress);
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
        emit inSwapAndLiquifyStatus(inSwapAndLiquify);
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

            _balances[recipient] = _balances[recipient].add(finalAmount);

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
        uint256 tokensForNft = tAmount.mul(_nftShare).div(_totalDistributionShares);
        uint256 tokensForApp = tAmount.mul(_appShare).div(_totalDistributionShares);

        uint256 tokensForSwap = tAmount.sub(tokensForLP).sub(tokensForNft).sub(tokensForApp);

        swapTokensForEth(tokensForSwap);

        uint256 amountReceived = address(this).balance;
        emit eventSwapAndLiquify(amountReceived);

        uint256 totalBNBFee = _totalDistributionShares.sub(_liquidityShare.div(2));
        uint256 amountBNBLiquidity = amountReceived.mul(_liquidityShare).div(totalBNBFee).div(2);
        uint256 amountBNBMarketing = amountReceived.sub(amountBNBLiquidity);

        emit marketingGetBnb(amountBNBMarketing);
        emit liquidityGetBnb(amountBNBLiquidity);
        emit tokenForNft(tokensForNft);
        emit tokenForApp(tokensForApp);

        if(tokensForApp>0)
            _basicTransfer(address(this),appWalletAddress,tokensForApp);
    
        if(tokensForNft >0)
            _basicTransfer(address(this),nftWalletAddress,tokensForNft);

        if(amountBNBMarketing > 0)
            transferToAddressETH(marketingWalletAddress, amountBNBMarketing);

        if(amountBNBLiquidity > 0 && tokensForLP > 0)
            addLiquidity(tokensForLP, amountBNBLiquidity);
    }
    
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the idex pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = idexV2Router.WETH();

        _approve(address(this), address(idexV2Router), tokenAmount);

        // make the swap
        idexV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(idexV2Router), tokenAmount);

        // add the liquidity
        idexV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
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

     function tokenETH() external view returns (address){
         return idexV2Router.WETH();
     }
    
}