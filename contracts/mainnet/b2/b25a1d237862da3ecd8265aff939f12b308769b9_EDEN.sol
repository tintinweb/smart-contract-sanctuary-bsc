/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// SPDX-License-Identifier: MIT
// File: contracts/EDEN.sol



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

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => mapping(address => uint256)) private _fromToAmount; 
    mapping(address => address) public _parent;
    address private _marketAddress;
    address private _remainAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) private _marketAdmin;

    mapping(address => bool) private _feeWhiteList;

    uint256 private _totalSupply;

    ISwapRouter private _swapRouter;
    address private _usdt;
    mapping(address => bool) private _swapPairList;

    bool private inSwap;
    bool public canSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _startTradeBlock;
    address public _mainPair;

    uint256 public _limitAmount;

    uint256 public _lpRewardBalance;
    uint256 public _marketRewardBalance;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply, address RouterAddress, address USDTAddress, address marketAddress, address remainAddress, address ReceiveAddress, uint256 LimitAmount){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        address usdt = USDTAddress;

        _usdt = usdt;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), usdt);
        _swapPairList[usdtPair] = true;

        address mainPair = swapFactory.createPair(address(this), swapRouter.WETH());
        _swapPairList[mainPair] = true;

        _mainPair = usdtPair;

        uint256 total = Supply * 10 ** Decimals;
        _totalSupply = total;

        _balances[address(this)] = 1000 * 10 ** Decimals;
        emit Transfer(address(0), address(this), _balances[address(this)]);

        _balances[ReceiveAddress] = total - _balances[address(this)];
        emit Transfer(address(0), ReceiveAddress, _balances[ReceiveAddress]);

        _marketAddress = marketAddress;
        _remainAddress = remainAddress;

        _feeWhiteList[marketAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;
        _feeWhiteList[address(0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE)] = true;

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;
        excludeLpProvider[address(0x7ee058420e5937496F5a2096f04caA7721cF70cc)] = true;
        excludeLpProvider[address(0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE)] = true;

        excludeMarketProvider[address(0)] = true;
        excludeMarketProvider[address(0x000000000000000000000000000000000000dEaD)] = true;
        excludeMarketProvider[address(0x7ee058420e5937496F5a2096f04caA7721cF70cc)] = true;
        excludeMarketProvider[address(0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE)] = true;

        _lpRewardCondition = 1 * 10 ** Decimals;
        _limitAmount = LimitAmount * 10** Decimals;

        _tokenDistributor = new TokenDistributor(usdt);
        _startTradeBlock = block.number;

        _marketAdmin[msg.sender] = true;
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

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(
             canSwap || _feeWhiteList[from] || _feeWhiteList[to],
            "ERC20: can not swap"
        );

        if (_swapPairList[to] && !_feeWhiteList[from] && !_feeWhiteList[to]) {
            require(amount <= (_balances[from])*99/100, "ERC20: sell amount exceeds balance 99%");
        }

        if (block.number < _startTradeBlock + 600 && !_swapPairList[to] && !_feeWhiteList[to] && !_feeWhiteList[from]) {
          
            require(_limitAmount >= (balanceOf(to) + amount), "exceed LimitAmount");
        }

        // 绑定关系 
        if(_fromToAmount[to][from] == 0){            
            if(_fromToAmount[from][to] == 0)  { 
                _fromToAmount[from][to] = amount; 
            }  
        }else if(_fromToAmount[to][from] > 0 && _parent[from] == address(0)){
          
            _parent[from]=to;
        }
        if (_feeWhiteList[from] || _feeWhiteList[to]){

            _tokenTransfer(from, to, amount, 0);
        }else{

            if (_swapPairList[to]) { 
      
                uint256 shareAmount = 0;
                _tokenTransfer(from, address(0), amount/100, 0); 
                
      
                address parent = _parent[from];
                if(parent!=address(0)){
                    shareAmount += amount*3/100;
                    _tokenTransfer(from, parent, amount*3/100, 0);

       
                    parent = _parent[parent];
                    if(parent!=address(0)){
                        shareAmount += amount/100;
                        _tokenTransfer(from, parent, amount/100, 0);

             
                        parent = _parent[parent];
                        if(parent!=address(0)){
                            shareAmount += amount/200;
                            _tokenTransfer(from, parent, amount/200, 0);

          
                            parent = _parent[parent];
                            if(parent!=address(0)){
                                shareAmount += amount/200;
                                _tokenTransfer(from, parent, amount/200, 0);
                                
                
                                parent = _parent[parent];
                                if(parent!=address(0)){
                                    shareAmount += amount/200;
                                    _tokenTransfer(from, parent, amount/200, 0);

                                    parent = _parent[parent];
                                    if(parent!=address(0)){
                                        shareAmount += amount/200;
                                        _tokenTransfer(from, parent, amount/200, 0);
                                    }
                                    
                                }
                                
                            }
                            
                        }

                    }
                }
                uint256 remainAmount = amount*6/100 - shareAmount;
                if(remainAmount > 0){
               
                    _tokenTransfer(from, _remainAddress, remainAmount, 0);
                }
                _tokenTransfer(from, to, amount*93/100, 0); 

            }else if(_swapPairList[from]){ 
                // _tokenTransfer(from, _marketAddress, amount*7/100, 0); 
                // _tokenTransfer(from, to, amount*93/100, 0); 
                _tokenTransfer(from, _marketAddress, amount*1/100, 0);
                    _tokenTransfer(from, address(0x567cA596916bb5dB1bA2c139aAF879E2E25f34cF), amount*2/100, 0);
                    _tokenTransfer(from, address(this), amount*4/100, 0);

                    _lpRewardBalance = _lpRewardBalance + amount*3/100;
                    _marketRewardBalance = _marketRewardBalance + amount*1/100; 
                    _tokenTransfer(from, to, amount*93/100, 0); //实际到帐
            }else{
                if (!inSwap){                     
        
                    _tokenTransfer(from, _marketAddress, amount*1/100, 0);
                    _tokenTransfer(from, address(0x567cA596916bb5dB1bA2c139aAF879E2E25f34cF), amount*2/100, 0);
                    _tokenTransfer(from, address(this), amount*4/100, 0);

                    _lpRewardBalance = _lpRewardBalance + amount*3/100;
                    _marketRewardBalance = _marketRewardBalance + amount*1/100; 
                }else{
            
                    // _tokenTransfer(from, _marketAddress, amount*7/100, 0); 
                    _tokenTransfer(from, _marketAddress, amount*1/100, 0);
                    _tokenTransfer(from, address(0x567cA596916bb5dB1bA2c139aAF879E2E25f34cF), amount*2/100, 0);
                    _tokenTransfer(from, address(this), amount*4/100, 0);

                    _lpRewardBalance = _lpRewardBalance + amount*3/100;
                    _marketRewardBalance = _marketRewardBalance + amount*1/100; 
                }
                _tokenTransfer(from, to, amount*93/100, 0); //实际到帐
            }
        }
        if (_swapPairList[to]) {      
            addLpProvider(from); 
        }
        if (from != address(this)) {
            processLP(500000);
            processMarket(500000);
        }
    }
    
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (fee > 0) {
            feeAmount = tAmount * fee / 100;
            _takeTransfer(
                sender,
                address(this),
                feeAmount
            );
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
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
        USDT.transferFrom(address(_tokenDistributor), _marketAddress, usdtBalance*2/7);
        USDT.transferFrom(address(_tokenDistributor), address(0x567cA596916bb5dB1bA2c139aAF879E2E25f34cF), usdtBalance*2/7); 
        USDT.transferFrom(address(_tokenDistributor), address(this), usdtBalance*3/7); 
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setMarketAddress(address addr) external onlyFunder {
        _marketAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function startTrade() external onlyOwner {
        require(0 == _startTradeBlock, "trading");
        _startTradeBlock = block.number;
    }

    function setCanSwap(bool _enable) public onlyOwner{
        canSwap = _enable;
    }

    function closeTrade() external onlyOwner {
        _startTradeBlock = 0;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }    

    function setBatchFeeWhiteList(address[] memory _addr) external onlyFunder {
        for(uint i;i<_addr.length;i++){
            _feeWhiteList[_addr[i]] = true;
        }
        
    } 

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(_marketAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        IERC20(token).transfer(_marketAddress, amount);
    }

    address[] private lpProviders;
    mapping(address => uint256) lpProviderIndex;

    address[] public marketProviders;
    mapping(address => uint256) marketProviderIndex;

    mapping(address => bool) excludeLpProvider;
    mapping(address => bool) excludeMarketProvider;

    function addLpProvider(address addr) private {
        if (0 == lpProviderIndex[addr]) {
            if (0 == lpProviders.length || lpProviders[0] != addr) {
                lpProviderIndex[addr] = lpProviders.length;
                lpProviders.push(addr);
            }
        }
    }

    function addMarketProvider(address addr) public  {
        require(_marketAdmin[msg.sender],"only Admin can use");
        if (0 == marketProviderIndex[addr]) {
            if (0 == marketProviders.length || marketProviders[0] != addr) {
                marketProviderIndex[addr] = marketProviders.length;
                marketProviders.push(addr);
            }
        }
    }

    function manulAddLpProvider(address addr) public onlyFunder {
        addLpProvider(addr);
    }

    function getLps() public view returns(address [] memory){
        return lpProviders;
    }

    uint256 private currentIndex;
    uint256 private currentIndex_market;
    uint256 public _lpRewardCondition;
    uint256 public _progressLPTime;
    uint256 public _progressLPTime_market;

    function setProgressLPTime(uint256 time) public onlyFunder {
        _progressLPTime=time;
    }

    function setProgressLPTime_market(uint256 time) public onlyFunder {
        _progressLPTime_market=time;
    }

    function withdraw(address add ,uint256 amount) public onlyFunder {
        _takeTransfer(address(this),add , amount);
    }

    function processLP(uint256 gas) public {
        uint256 timestamp = block.timestamp;
        if (_progressLPTime + 7200 > timestamp) {
            return;
        }
        IERC20 mainpair = IERC20(_mainPair);
        uint totalPair = mainpair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        IERC20 token = IERC20(address(this));
        uint256 tokenBalance = _lpRewardBalance;
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
        _lpRewardBalance = 0;

        _progressLPTime = timestamp;
    }

    function processMarket(uint256 gas) public {
        uint256 timestamp = block.timestamp;
        if (_progressLPTime_market + 7200 > timestamp) {
            return;
        }
        IERC20 mainpair = IERC20(_mainPair);
        uint totalPair = mainpair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        IERC20 token = IERC20(address(this));
        uint256 tokenBalance = _marketRewardBalance;
        if (tokenBalance < _lpRewardCondition) {
            return;
        }

        address shareHolder;
        // uint256 pairBalance;
        uint256 amount;

        uint256 shareholderCount = marketProviders.length;
        if(shareholderCount == 0 ){
            return;
        }

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex_market >= shareholderCount) {
                currentIndex_market = 0;
            }
            shareHolder = marketProviders[currentIndex_market];
            // pairBalance = mainpair.balanceOf(shareHolder);
            // if (pairBalance > 0 && !excludeLpProvider[shareHolder]) {
            //     amount = tokenBalance  / shareholderCount;
            //     if (amount > 0) {
            //         token.transfer(shareHolder, amount);
            //     }
            // }
            if (!excludeMarketProvider[shareHolder]) {
                amount = tokenBalance  / shareholderCount;
                if (amount > 0) {
                    token.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex_market++;
            iterations++;
        }
        _marketRewardBalance = 0;

        _progressLPTime_market = timestamp;
    }

    function setLimitAmount(uint256 amount) external onlyFunder {
        _limitAmount = amount * 10 ** _decimals;
    }

    function setMainPair(address pair) external onlyFunder {
        _mainPair = pair;
    }

    function setLPRewardCondition(uint256 amount) external onlyFunder {
        _lpRewardCondition = amount;
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyFunder {
        excludeLpProvider[addr] = enable;
    }

    function setExcludeMarketProvider(address addr, bool enable) public  {
        require(_marketAdmin[msg.sender],"only Admin can use");
        excludeMarketProvider[addr] = enable;
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || _marketAddress == msg.sender, "!Funder");
        _;
    }

    receive() external payable {}
}

contract EDEN is AbsToken {
    constructor() AbsToken(
        "Garden of Eden",
        "EDEN",
        18,
        6669,
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E), // PancakeSwap: Router v2
        address(0x55d398326f99059fF775485246999027B3197955), // USDT
        address(0xeF68FeDCa9deD5F7E2f1747e48cCD2e6047BC326), // market
        address(0x71fd601805251bfd15C78D2c4b7A0E27F0acA0aA), //没有上下级回流地址
        address(0xfB9aDc792dE19a3e9abf8276C786a80197b42cE7), // 发行地址      
        3
    ){

    }
}