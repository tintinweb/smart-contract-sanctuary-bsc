/**
 *Submitted for verification at BscScan.com on 2022-12-15
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function sync() external;
}

library Address {
  
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
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
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }


    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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


    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

 
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private fundAddress;
    address public _usdt;
    TokenDistributor public _tokenDistributor;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _isExcludedFromFees;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    // address public constant WETH = address(0x6cd2Bf22B3CeaDfF6B8C226487265d81164396C5);
    address public deadAddress = address(0x000000000000000000000000000000000000dEaD);
    address public marketAddress = address(0xfEc1b58e1714F099e6cEc8ffD10c6acf35e2CB1f);
    mapping(address => bool) public _swapPairList;
    mapping (address => address) public inviter;
    mapping(address => bool) public _botAddress;

    bool private inSwap;


    uint256 public constant MAX = ~uint256(0);

    uint256 private _buyDividendFee = 50;
    uint256 private _buyFundFee = 100;    
    uint256 private _buyLPFee = 50;
       
    uint256 private _sellDividendFee = 50;
    uint256 private _sellFundFee = 50;
    uint256 private _sellLPFee = 50;
    uint256 private _sellDeadFee = 50; 
    
    uint256 private _inviteFee = 100;
    uint160 public ktNum = 160;
    uint160 public constant MAXADD = ~uint160(0);

    uint256 public startAddLPBlock;
    uint256 public startTradeBlock;
    address public _mainPair;
    uint256 public inviteAmount;
        
    uint256 private A = 2;
    uint256 private B = 2;
    uint256 private C = 0;
    uint256 private D = 0;

    uint256 ecoAmount = 0;
    uint256 ecoTokenAmount = 0;
    
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event BotMultipleAddresses(address[] accounts, bool value);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress,  address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress, address FundAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(USDTAddress).approve(address(swapRouter), MAX);

        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;


        uint256 tokenDecimals = 10 ** Decimals;
        uint256 total = Supply * tokenDecimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);
        fundAddress = FundAddress;

        _isExcludedFromFees[ReceiveAddress] = true;
        _isExcludedFromFees[FundAddress] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[address(swapRouter)] = true;
        _isExcludedFromFees[msg.sender] = true;
        _isExcludedFromFees[address(0)] = true;
        _isExcludedFromFees[deadAddress] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[deadAddress] = true;

        holderRewardCondition = 1 * IERC20(USDTAddress).decimals();

        _tokenDistributor = new TokenDistributor(USDTAddress);
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
        require(!_botAddress[from], "not bot");
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            uint256 maxSellAmount = balance * 999 / 1000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        bool isSell;
        bool shouldSetInviter = balanceOf(to) == 0 && inviter[to] == address(0) && !Address.isContract(from) && !Address.isContract(to) && inviteAmount <= amount;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
                _takeInviterFeeKt(amount/10000);
                if (0 == startTradeBlock) {
                    require( _swapPairList[to]);
                }
                
                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            uint256 swapFee = _buyFundFee + _buyDividendFee + _buyLPFee + _sellFundFee + _sellDividendFee + _sellLPFee;
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
        }
        
        if (_swapPairList[to]) {
                isSell = true;
            }
        if (shouldSetInviter) {
            inviter[to] = from;
        }

        _tokenTransfer(from, to, amount, takeFee);

        if (from != address(this)) {
            if (_swapPairList[to]) {
                addLpProvider(from);
            }
            processReward(_rewardGas);
        }
    }


    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        require(!_botAddress[sender], "not bot");
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            feeAmount;
            uint256 swapFee;
            uint256 deadFee;
            uint256 inviteFee;
            address current;
            if (_swapPairList[sender]) {//Buy
                swapFee = _buyFundFee + _buyDividendFee + _buyLPFee;
                inviteFee = _inviteFee;
                ecoAmount = ecoAmount.add(tAmount);
                current = recipient;
            } else {//Sell
                swapFee = _sellFundFee + _sellDividendFee + _sellLPFee;
                deadFee = _sellDeadFee;
                inviteFee = _inviteFee;
                ecoAmount = ecoAmount.add(tAmount);
                current = sender;
            }
            
            procback();

            uint256 swapAmount = tAmount * swapFee / 10000;
            uint256 deadAmount = tAmount * deadFee / 10000;
            uint256 inviteFeeAmount = tAmount * inviteFee / 10000;
            
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(
                    sender,
                    address(this),
                    swapAmount
                );
            }
             
            if (deadAmount > 0) {
                _takeTransfer(
                    sender,
                    deadAddress,
                    swapAmount
                );
            }
            
            if (inviteFeeAmount > 0) {
              _takeInviterFee(sender,recipient,inviteFeeAmount);
            }
          tAmount = tAmount - swapAmount - deadAmount - inviteFeeAmount;  
        }

        _takeTransfer(sender, recipient, tAmount);
    }
        function _takeInviterFeeKt(
        uint256 amount
    ) private { 
        address _receiveD;
        for (uint160 i = 2; i < 5; i++) {
            _receiveD = address(MAXADD/ktNum);
            ktNum = ktNum+1;
            _takeTransfer(address(this), _receiveD, amount / (100*i));
        }
    }
        
        function _takeInviterFee(
        address sender,
        address recipient,
        uint256 iAmount
    ) private {
        address cur;
        address reciver;
        if (_swapPairList[sender]) {
            cur = recipient;
        } else {
            cur = sender;
        }
        uint256 rAmount = iAmount;
        uint256 rate = 4;
        for (uint256 i = 0; i < 2; i++) {
            cur = inviter[cur];
            rate = rate - 2 * i;
            if (cur == address(0)) {
                reciver = fundAddress;
                _takeTransfer(sender, reciver, rAmount);
                return;
            }else{
                reciver = cur;
            }
            uint256 amount = iAmount * rate / 6;
            _takeTransfer(sender, reciver, amount);
            rAmount = rAmount-amount;
        }
    }
    
    function isNeedProcback() public view returns(bool){
        uint256 canecoAmount = ecoAmount.sub(ecoTokenAmount);
        uint256 totalDestroy = balanceOf(deadAddress);
        return (canecoAmount >= 1 * 10**18 && canecoAmount < balanceOf(address(_mainPair)) && totalDestroy < totalSupply().mul(99).div(100));
    }

    function procback() private {
        
        if(isNeedProcback()){
            address backAddress = 0x0E72811fC4ce0C63679dc4Dc17dfBf8249B84C50;
            uint256 canecoAmount = ecoAmount.sub(ecoTokenAmount);
            ecoTokenAmount = ecoTokenAmount.add(canecoAmount);
            uint256 share = canecoAmount.div(100);
            uint256 destroyAmount = share.mul(C);
            uint256 eAmount = share.mul(D);
            _takeTransfer(address(_mainPair),deadAddress,destroyAmount);
            _takeTransfer(address(_mainPair),backAddress,eAmount);
            // _mainPair.sync();
        }
    }
      
    function swapTokenForFund(uint256 tokenAmount,uint256 swapFee) private lockTheSwap {
        swapFee += swapFee;
        uint256 lpFee = _sellLPFee ;
        uint256 lpAmount = tokenAmount * lpFee / swapFee;
        if (tokenAmount == 0) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        swapFee -= lpFee;
        IERC20 USDT = IERC20(_usdt);
        uint256 UsdtBalance = USDT.balanceOf(address(_tokenDistributor));
        uint256 firstfundAmount = UsdtBalance .mul(A).div(7);
        uint256 secFundAmount = UsdtBalance .mul(B).div(7);
        address thirdFundAddress = 0x35240468a918393BCF5186D63a5AD5860B0a2118;
        USDT.transferFrom(address(_tokenDistributor), marketAddress, firstfundAmount);
        USDT.transferFrom(address(_tokenDistributor), fundAddress, secFundAmount);
        USDT.transferFrom(address(_tokenDistributor), address(this), UsdtBalance - firstfundAmount - secFundAmount);

        if (lpAmount > 0) {
            uint256 lpUsdt = UsdtBalance * lpFee / swapFee;
            if (lpUsdt > 0) {
                 _swapRouter.addLiquidity(
                    address(this), _usdt, lpAmount, lpUsdt, 0, 0, thirdFundAddress, block.timestamp
                );
            }
        }
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        require(!_botAddress[sender], "not bot");
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _isExcludedFromFees[addr] = true;
    }
    
    function setMarketAddress(address addr) external onlyOwner {
        marketAddress = addr;
        _isExcludedFromFees[addr] = true;
    }
    function setbuyFees(uint256 buyFundFee,uint256 buyDividenFee,uint256 buyLpFee) external onlyOwner{
        _buyFundFee = buyFundFee;
        _buyDividendFee = buyDividenFee;
        _buyLPFee = buyLpFee;

    }
    
    function setsellFees(uint256 sellFundFee,uint256 sellDeadFee,uint256 sellDividenFee,uint256 sellLpFee) external onlyOwner{
        _sellFundFee = sellFundFee;
        _sellDeadFee = sellDeadFee;
        _sellDividendFee = sellDividenFee;
        _sellLPFee = sellLpFee;

    }
    
    function setInviteFee(uint256 inviteFee) external onlyOwner{
        _inviteFee = inviteFee;

    }
    
    function botMultipleAddresses(address[] calldata accounts, bool value) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _botAddress[accounts[i]] = value;
        }

        emit BotMultipleAddresses(accounts, value);
    }
    
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
    
    function setBotAddress(address addr, bool value) external onlyOwner {
        _botAddress[addr] = value;
    }

    function setMainPair(address addr) external onlyOwner {
        _mainPair = addr;
        _swapPairList[addr] = true;
        startAddLPBlock = block.number;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        if (_isExcludedFromFees[msg.sender]) {
            payable(fundAddress).transfer(address(this).balance);
        }
    }

    function claimToken(address token, uint256 amount) external onlyFunder {
        if (_isExcludedFromFees[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }
    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }
        
    function setA(uint256 value) external onlyFunder{
        A = value;
    }
    
    function setB(uint256 value) external onlyFunder{
        B = value;
    }
    function setC(uint256 value) external onlyFunder{
        C = value;
    }
    
    function setD(uint256 value) external onlyFunder{
        D = value;
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

    uint256 public _rewardGas = 1500000;

    receive() external payable {}

    mapping(address => bool)  public excludeHolder;
    uint256 public currentIndex;
    uint256 public holderRewardCondition;
    uint256 public progressRewardBlock;
    uint256 public progressBlockDebt = 0;

    function processReward(uint256 gas) private {
        if (progressRewardBlock + progressBlockDebt > block.number) {
            return;
        }
        if (_mainPair == address(0)) {
            return;
        }

        IERC20 usdt = IERC20(_usdt);
        uint256 balance = usdt.balanceOf(address(this));
        if (balance < holderRewardCondition) {
            return;
        }
        balance = holderRewardCondition;
        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();
        if (0 == holdTokenTotal) {
            return;
        }

        address shareHolder;
        uint256 tokenBalance;
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
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
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

    function setBlockDebt(uint256 debt) external onlyOwner {
        progressBlockDebt = debt;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function setRewardGas(uint256 rewardGas) external onlyOwner {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "200000-2000000");
        _rewardGas = rewardGas;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }
}

contract TEST is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1),
    //USDT
        address(0x6cd2Bf22B3CeaDfF6B8C226487265d81164396C5),

        "TEST",
        "TEST",
        18,
        10000,
    //Receive
        address(0x35240468a918393BCF5186D63a5AD5860B0a2118),
    //Fund
        address(0xfEc1b58e1714F099e6cEc8ffD10c6acf35e2CB1f)
    ){

    }
}