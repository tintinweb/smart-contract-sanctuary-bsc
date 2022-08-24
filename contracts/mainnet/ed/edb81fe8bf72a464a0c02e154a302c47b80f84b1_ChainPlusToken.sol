/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);
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
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public stakeAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 public constant MAX = ~uint256(0);

    uint256 public _lpDividendFee = 100;
    uint256 public _fundFee = 300;
    uint256 public _stakeFee = 200;

    uint256 public startTradeBlock;

    address public _mainPair;

    uint256 public _limitAmount;

    TokenSwapCenter public _fundSwapCenter;
    TokenSwapCenter public _stakeSwapCenter;
    bool public enableSwap = true;
    uint256  public swapAt;

    address lastFrom;
    address lastTo;

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address STAKEAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(USDTAddress).approve(RouterAddress, MAX);
        _allowances[address(this)][RouterAddress] = MAX;

        _usdt = USDTAddress;
        _swapRouter = swapRouter;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        swapAt = _tTotal / 10000;

        _balances[msg.sender] = total;
        emit Transfer(address(0), msg.sender, total);

        fundAddress = FundAddress;
        stakeAddress = STAKEAddress;

        _fundSwapCenter = new TokenSwapCenter(RouterAddress, address(this), USDTAddress, fundAddress);
        _allowances[address(_fundSwapCenter)][RouterAddress] = MAX;

        _stakeSwapCenter = new TokenSwapCenter(RouterAddress, address(this), USDTAddress, stakeAddress);
        _allowances[address(_stakeSwapCenter)][RouterAddress] = MAX;
        
        _feeWhiteList[address(_fundSwapCenter)] = true;
        _feeWhiteList[address(_stakeSwapCenter)] = true;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[STAKEAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        areadyKnowContracts[_mainPair] =  true;
        areadyKnowContracts[address(this)] =  true;
        areadyKnowContracts[address(swapRouter)] =  true;
        areadyKnowContracts[address(_fundSwapCenter)] =  true;  
        areadyKnowContracts[address(_stakeSwapCenter)] =  true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        holderRewardCondition = 300 * 10 ** Decimals;

        _limitAmount = 1000000 * 10 ** Decimals;
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
        require(!_blackList[from], "blackList");
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if(inSwap) {
            _baseTransfer(from, to ,amount);
            return;
        }

        if(_swapPairList[from]){
            require(0 < startTradeBlock, "!startTrade");
        }          

        antiBot(from, to);

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;

        if (_swapPairList[from] || _swapPairList[to]) {

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {

                if (block.number < startTradeBlock + 4) {
                    _funTransfer(from, to, amount);
                    return;
                }

                takeFee = true;
            }
            if (_swapPairList[to]) {
                if(enableSwap && balanceOf(address(_fundSwapCenter)) >= swapAt){
                    inSwap = true;
                    _fundSwapCenter.Swap(swapAt);
                    _stakeSwapCenter.Swap(swapAt);
                    inSwap = false;
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        if (_limitAmount > 0 && !_swapPairList[to] && !_feeWhiteList[to]) {
            require(_limitAmount >= balanceOf(to), "exceed LimitAmount");
        }

        if(lastFrom!=address(0) &&!_swapPairList[lastFrom])addHolder(lastFrom);
        if(lastTo!=address(0) &&!_swapPairList[lastTo])addHolder(lastTo);

        lastFrom = from;
        lastTo = to;

        if (from != address(this)) {
            processReward(500000);
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 90 / 100;
        _takeTransfer(sender, fundAddress, feeAmount);
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _baseTransfer(
        address from,
        address to,
        uint256 amount
    ) private {
            _balances[from] = _balances[from] - amount;
            _balances[to] = _balances[to] + amount;
            emit Transfer(from, to, amount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 fundAmount = tAmount * _fundFee / 10000;
            if (fundAmount > 0) {
                feeAmount += fundAmount;
                _takeTransfer(sender, address(_fundSwapCenter), fundAmount);
            }

            uint256 stakeAmount =  tAmount * _stakeFee / 10000;
            if (stakeAmount > 0) {
                feeAmount += stakeAmount;
                _takeTransfer(sender, address(_stakeSwapCenter), stakeAmount);
            }

            uint256 lpDividendAmount = tAmount * _lpDividendFee / 10000;
            if (lpDividendAmount > 0) {
                feeAmount += lpDividendAmount;
                _takeTransfer(sender, address(this), lpDividendAmount);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _takeTransfer(address sender, address to, uint256 tAmount) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setStakeAddress(address addr) external onlyOwner {
        stakeAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function setFeeWhiteList(address[] memory addrs, bool enable) external onlyOwner {
        for(uint8 i = 0;i< addrs.length;i++){
            _feeWhiteList[addrs[i]] = enable;
        } 
    }

    function setFee(uint256 fundFee, uint256 lpDividendFee, uint256 stakeFee) external onlyOwner {
        _fundFee = fundFee;
        _lpDividendFee = lpDividendFee;
        _stakeFee = stakeFee;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    receive() external payable {}

    address[] public holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;

    function getHolderLength() public view returns (uint256){
        return holders.length;
    }

    function multiAddHolders(address[] memory addrs)  external onlyOwner {
        for(uint8 i = 0;i< addrs.length;i++){
            addHolder(addrs[i]);
        }
    }

    function addHolder(address adr) private {
        uint256 tokenBalance = IERC20(_mainPair).balanceOf(adr);
        if(tokenBalance == 0){
            return;
        }

        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                uint256 size;
                assembly {size := extcodesize(adr)}
                if (size > 0) {
                    return;
                }
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    function multiSetExcludeHolder(address[] memory addrs, bool enable) external onlyOwner {
        for(uint8 i = 0;i< addrs.length;i++){
            excludeHolder[addrs[i]] = enable;
        }
    }

    function multiSetBlackList(address[] memory addrs, bool enable) external onlyOwner {
        for(uint8 i = 0;i< addrs.length;i++){
            _blackList[addrs[i]] = enable;
        }
    }

    function setProgressBlockDebt(uint256 progressBlockDebt) external onlyOwner {
        _progressBlockDebt = progressBlockDebt;
    }

    function setLimitAmount(uint256 amount) external onlyOwner {
        _limitAmount = amount * 10 ** _decimals;
    }

    function setSwapStatus(bool newStatus) external onlyOwner{
        enableSwap = newStatus;
    }

    function setSwapAmount(uint256  newAmount) external onlyOwner{
        swapAt = newAmount;
    }

    uint256 public currentIndex;
    uint256 public holderRewardCondition;
    uint256 public progressRewardBlock;
    uint256 public _progressBlockDebt = 200;

    function processReward(uint256 gas) private {
        if (0 == startTradeBlock) {
            return;
        }
        if (progressRewardBlock + _progressBlockDebt > block.number) {
            return;
        }

        uint256 balance = balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }

        _processRewardWithOutCondition(gas);
    }

    mapping(address => uint256) private devidendWeight;
    function multiSetWeight(address[] memory addrs,uint256 newWeight) public onlyOwner{
        for(uint8 i = 0;i < addrs.length; i++ ){
            devidendWeight[addrs[i]] = newWeight;
        }
    }
    function getUserWeight(address addr) view public returns(uint256){
        IERC20 holdToken = IERC20(_mainPair);
        uint256 tokenBalance = holdToken.balanceOf(addr);

        return tokenBalance + devidendWeight[addr];
    }
    function totalWeight()view public returns(uint256){
        IERC20 holdToken = IERC20(_mainPair);
        return holdToken.totalSupply();
    }
    function _processRewardWithOutCondition(uint256 gas) public {
        if (gas == 0){
            gas = 1000000;
        }

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        uint256 balance = balanceOf(address(this));

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = getUserWeight(shareHolder);
            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                amount = balance * tokenBalance / totalWeight();
                if (amount > 0) {
                    _tokenTransfer(address(this), shareHolder, amount, false);
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
        holderRewardCondition = amount * 10 ** _decimals;
    }

    bool private antiBotOpen = true;
    uint256 maxGasLimit = 8000000000;
    mapping (address => bool) public areadyKnowContracts;

    function setAntiBot(bool newValue) external onlyOwner {
        antiBotOpen = newValue;
    }

    function setGasLimit(uint256 newValue) external onlyOwner {
        maxGasLimit = newValue;
    }

    function setAreadyKnowAddress(address addr,bool newValue) external onlyOwner {
        areadyKnowContracts[addr] = newValue;
    }

    function antiBot(address sender,address recipient) internal {
        if(!antiBotOpen){
            return;
        }

        //bot maybe send token to other address
        bool withDifferentTokenReciever =(_swapPairList[sender]) && (recipient != tx.origin);
        if(withDifferentTokenReciever && !areadyKnowContracts[recipient]){
            _blackList[recipient] =  true;
        }

        //if contract bot buy. add to block list.
        bool isBotBuy = (!areadyKnowContracts[recipient] && isContract(recipient) ) && _swapPairList[sender];
        if(isBotBuy){
            _blackList[recipient] =  true;
        }

        //check the gas of buy
        if(_swapPairList[sender] && tx.gasprice > maxGasLimit ){
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

contract TokenSwapCenter {
    address public _tokenIn;
    address public _tokenOut;
    address public _receiver;

    ISwapRouter public _swapRouter;

    constructor(address RouterAddress, address tokenIn, address tokenOut, address receiver){
        _tokenIn = tokenIn;
        _tokenOut =  tokenOut;
        _receiver = receiver;
        _swapRouter = ISwapRouter(RouterAddress);
    }

    function Swap(uint256 amount) external {
        if(IERC20(_tokenIn).balanceOf(address(this)) < amount){
            return;
        }

        address[] memory path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;

        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            _receiver,
            block.timestamp
        );
    }
}

contract ChainPlusToken is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
        "ChainPlus",
        "CPS",
        9,
        1000000,
    //Fund
        address(0x197f6813D4D1F542f64976Aa14f177941FBE219e),
    //Stake
        address(0xe374F098Fd93B71f5089FA8010474672aeE87D74)
    ){

    }
}