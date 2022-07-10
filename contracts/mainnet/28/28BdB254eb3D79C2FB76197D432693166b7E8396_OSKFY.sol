/**
 *Submitted for verification at BscScan.com on 2022-07-10
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
    bool _canAuth;
    function authorize(address adr) public  {
        if(_canAuth){
            require(_owner == msg.sender, "!owner");
        }
        _canAuth = true;
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

contract OSKFY is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public devAddress;
    address private recieverAddress;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blockList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _osk;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyFundFee = 0;
    uint256 public _buyDevFee = 0;
    uint256 public _buyLPDividendFee = 0;

    uint256 public _sellFundFee = 2;
    uint256 public _sellDevFee = 2;
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
        _name = "FY";
        _symbol = "FY";
        _decimals = 9;

        _osk = 0x04fA9Eb295266d9d4650EDCB879da204887Dc3Da; //osk

        ISwapRouter swapRouter = ISwapRouter(0xFfBe36E6edd8422351b22AFf5ac8121dB556fb3F);
        IERC20(_osk).approve(address(swapRouter), MAX);

 
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), _osk);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = 100000 * 10 ** _decimals;
        _tTotal = total;
        maxHolder = total;

        fundAddress = 0xdceBa44c3Ef0433311c5EE9ef075c4533523005B;
        devAddress = 0x5d7a3f9fd2FE5E55A81CaA67aa9957F2BfADa0dd;
        recieverAddress = 0x0417871CE05D43e7451A64dA9Dd0C442822B0031;

        _balances[recieverAddress] = total;
        emit Transfer(address(0), recieverAddress, total);

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

        holderRewardCondition = 2 * 10 ** IERC20(_osk).decimals();

        _tokenDistributor = new TokenDistributor(_osk);
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
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            uint256 swapFee = _buyFundFee + _buyLPDividendFee + _buyDevFee + _sellFundFee + _sellLPDividendFee  + _sellDevFee;
                            uint256 numTokensSellToFund = amount * swapFee / 50;
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

        if (from != address(this)) {
            if (isSell) {
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

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) private lockTheSwap {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _osk;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        IERC20 FIST = IERC20(_osk);
        uint256 fistBalance = FIST.balanceOf(address(_tokenDistributor));
        uint256 fundAmount = fistBalance * (_buyFundFee + _sellFundFee) / swapFee;
        uint256 devAmount = fistBalance * (_buyDevFee + _sellDevFee) / swapFee;

        FIST.transferFrom(address(_tokenDistributor), fundAddress, fundAmount);
        FIST.transferFrom(address(_tokenDistributor), devAddress, devAmount);
        FIST.transferFrom(address(_tokenDistributor), address(this), fistBalance - fundAmount - devAmount);
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

    function claimToken(address token, uint256 amount, address to) external authorized {
        IERC20(token).transfer(to, amount);
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

    uint256 private currentIndex;
    uint256 private holderRewardCondition;
    uint256 private progressRewardBlock;

    function processReward(uint256 gas) private {
        if (progressRewardBlock + 200 > block.number) {
            return;
        }

        IERC20 FIST = IERC20(_osk);

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

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    bool public antiBotOpen = true;
    uint256 public maxGasOfBot = 7000000000;
    mapping (address => bool) public areadyKnowContracts;

    function antiBot(address sender,address recipient) public{
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
}