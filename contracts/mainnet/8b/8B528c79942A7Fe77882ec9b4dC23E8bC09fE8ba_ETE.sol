/**
 *Submitted for verification at BscScan.com on 2022-08-21
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

interface IMarket {
    function addContractBalance(uint256 amount) external;
}

contract TokenDistributor {
    constructor (address USDT) {
        IERC20(USDT).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address public _marketAddress; 
    address public _techAddress; 
    address public _nftAddress; 
    address public _receiveAddress;

    bool public _startTradeFlg;
    
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList; // 黑名单就是指定地址不能交易
    mapping(address => bool) private _swapPairList;
    uint256 private constant MAX = ~uint256(0);
    address private _mainPair;
    address private _usdtAddress;
    ISwapRouter _swapRouter;
    TokenDistributor private _tokenDistributor;

    constructor (string memory tokenName, string memory tokenSymbol, uint8 tokenDecimals, uint256 tokenSupply, 
        address routerAddress, address usdtAddress, address techAddress, address marketAddress, address receiveAddress){
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = tokenDecimals;

        _swapRouter = ISwapRouter(routerAddress);

        _usdtAddress = usdtAddress;
        _allowances[address(this)][routerAddress] = MAX;

        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), _usdtAddress);
        _swapPairList[usdtPair] = true;


        _mainPair = usdtPair;

        uint256 total = tokenSupply * 10 ** tokenDecimals;
        _totalSupply = total;

        _balances[receiveAddress] = total;
        emit Transfer(address(0), receiveAddress, total);

        _receiveAddress = receiveAddress; 
        _techAddress = techAddress; // 技术
        _marketAddress = marketAddress; // 营销

        _feeWhiteList[marketAddress] = true;
        _feeWhiteList[techAddress] = true;
        _feeWhiteList[receiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[routerAddress] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        _lpRewardCondition = 10 * 10 ** IERC20(usdtAddress).decimals();
        _tokenDistributor = new TokenDistributor(usdtAddress);
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

    function _transfer(address from, address to, uint256 amount) private {
        if (_feeWhiteList[from] || _feeWhiteList[to]){
            // from和to有一个是白名单用户就不扣手续费，正常转账
            _tokenTransfer(from, to, amount);
        }else{
            require(_startTradeFlg, "ETE: trade closed");
            if (amount >= balanceOf(from)) { // 全转出
                uint256 remainAmount = 10 ** (_decimals - 4); // 0.00001
                if (amount < remainAmount) {
                    require(amount>=remainAmount, "ETE: shuld leave 0.00001 in your address"); // 一点都不让转出了
                } else {
                    amount -= remainAmount;
                }
            }
            if (_swapPairList[from]) { // 买,减池子
                _tokenTransfer(from, address(this), amount/20);  
                _tokenTransfer(from, to, amount*95/100); // 实际到帐

            }else if (_swapPairList[to]) { // 卖，加池子
                _tokenTransfer(from, address(this), amount/20);  
                swapUsdt();
                _tokenTransfer(from, to, amount*95/100); // 实际到帐

            }else{
                // 普通转账
                _tokenTransfer(from, to, amount);
            }
        }

        if(_swapPairList[to]){
            addLpProvider(from);
        }
        
        if (from != address(this)) {
            processLP(500000);
        }
    }
    
    function swapUsdt() internal {
		address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdtAddress;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            balanceOf(path[0]),
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );
        IERC20 USDT = IERC20(_usdtAddress);
        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));
        USDT.transferFrom(address(_tokenDistributor), address(this), usdtBalance*15/50);
        USDT.transferFrom(address(_tokenDistributor), _nftAddress, usdtBalance*15/50);        
        USDT.transferFrom(address(_tokenDistributor), _techAddress, usdtBalance/5);
        USDT.transferFrom(address(_tokenDistributor), _marketAddress, usdtBalance/5);
        IMarket(_nftAddress).addContractBalance(usdtBalance*15/50); 
    }
    
    function _tokenTransfer(address sender, address recipient, uint256 tAmount ) private {
        _balances[sender] -= tAmount;
        _balances[recipient] += tAmount;
        emit Transfer(sender, recipient, tAmount);
    }

    //////////// address api
    function setNftAddress(address addr) external onlyOwner {
        _nftAddress = addr;
        _feeWhiteList[addr] = true;
    }
     // 白名单地址免手续费
    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }   
    
    // 设置黑名单，不能交易，而且币会清空，转入发币地址
    function setBlackList(address addr, bool enable) external onlyOwner {
        _tokenTransfer(addr, _receiveAddress, balanceOf(addr)); // 扣除这个地址上余额
        _blackList[addr] = enable;
    }   
    
    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function startTrade() external onlyOwner {
        _startTradeFlg = true;
    }

    function closeTrade() external onlyOwner {
        _startTradeFlg = false;
    }
    
    address[] private _lpProviderList;
    mapping(address => bool) public _lpProviderMap;

    function addLpProvider(address account) internal {
        if (account!=address(0) && account != address(0x000000000000000000000000000000000000dEaD) && false == _lpProviderMap[account]) {
            _lpProviderList.push(account);
            _lpProviderMap[account]=true;
        }
    }
    function getLpProviderList() public view returns(address[] memory){
        return _lpProviderList;
    }
    function getLpProviderSize() public view returns(uint256){
        return _lpProviderList.length;
    }

    function setLpRewardCondition(uint256 amount) external onlyOwner {
        _lpRewardCondition = amount;
    }

    function setProgressLpTime(uint256 time) external onlyOwner {
        _progressLpTime = time;
    }
    
    function setProgressLpInterval(uint256 time) external onlyOwner {
        _progressLpTime = time;
    }

    uint256 private _currentIndex;
    uint256 public _lpRewardCondition;
    uint256 public _progressLpTime;
    uint256 public _progressLpInterval = 86400;

    function processLP(uint256 gas) internal {
        uint256 timestamp = block.timestamp;
        if (_progressLpTime + _progressLpInterval > timestamp) {
            return;
        }
        IERC20 mainpair = IERC20(_mainPair);
        uint totalPair = mainpair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        IERC20 USDT = IERC20(_usdtAddress);
        uint256 tokenBalance = USDT.balanceOf(address(this));
        if (tokenBalance < _lpRewardCondition) {
            return;
        }

        address shareHolder;
        uint256 pairBalance;
        uint256 amount;

        uint256 shareholderCount = _lpProviderList.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (_currentIndex >= shareholderCount) {
                _currentIndex = 0;
            }
            shareHolder = _lpProviderList[_currentIndex];
            pairBalance = mainpair.balanceOf(shareHolder);
            if (pairBalance > 0) {
                amount = tokenBalance * pairBalance / totalPair;
                if (amount > 0) {
                    USDT.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            _currentIndex++;
            iterations++;
        }

        _progressLpTime = timestamp;
    }
    receive() external payable {}
}

contract ETE is AbsToken {
    constructor() AbsToken(
        "Eternal",
        "ETE",
        18,
        2100000000, // 21亿
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E), // PancakeSwap: Router v2
        address(0x55d398326f99059fF775485246999027B3197955), // USDT
        address(0xe4D97bDDa3aA8Ee5ca681458aDaD21Ddd0558dC0), 
        address(0xe65bbc528219a3b4410a023CC89DC59C6E6a82e2), 
        address(0x3A58ac648e88Ae7AA967E95271201cFBBF3caaA7)  // 发行地址    
    ){

    }
}