/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

//SPDX-License-Identifier: MIT
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
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
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

abstract contract BBKToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _tTotal;
    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;
    uint256 private constant MAX = ~uint256(0);
    uint256 public free = 500;
    address public _mainPair;
    address[] public holders;
    uint256 public holdersBlock = 1200;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;
    uint256 public currentIndex;
    uint256 public holderRewardCondition;
    uint256 public progressRewardBlock;
    uint public excludeHolderNumber;
    mapping(address => bool) public _isExcludedFromFee;
    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), _usdt);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;
        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;
        _balances[msg.sender] = total;
        emit Transfer(address(0), msg.sender, total);
        excludeHolder[address(0)] = true;
        _isExcludedFromFee[msg.sender] = true;
        excludeHolder[RouterAddress] = true; //排除路由
        excludeHolder[msg.sender] = true; //项目方自己不要
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        holderRewardCondition = 10 * 10 ** Decimals;
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
        require(amount>0);
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            _balances[from] = _balances[from] - amount;
            _takeTransfer(from,to,amount);
            return;
        }
        _tokenTransfer(from, to, amount);
         processReward(500000);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        bool isAddLdx;

        if (_swapPairList[sender]) {//Buy
            feeAmount = tAmount * free / 10000;
        } else if(_swapPairList[recipient]) { //sell
            isAddLdx = _isAddLiquidity(); //判断是否加池子
            feeAmount = tAmount * free / 10000;
            //是加池子
            if(isAddLdx && !isContract(sender)){
                feeAmount = 0; //手续费为0 
                addHolder(sender); //添加持有人
            }
        }
        if (feeAmount > 0) {
             _takeTransfer(
                sender,
                address(this),
                feeAmount
            );
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }


    function excludeMultipleAccountsFromFee(
        address[] calldata accounts,
        bool excluded
    ) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = excluded;
        }
    }

    //设置池子
    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }
    receive() external payable {}
    function getHolderLength() public view returns (uint256){
        return holders.length;
    }
    function addHolder(address adr) private {
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                uint256 size;
                assembly {size := extcodesize(adr)}
                if (size > 0) {
                    return;
                }
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }
    function processReward(uint256 gas) private {
        if (progressRewardBlock + holdersBlock > block.number) {
            return;
        }
        uint256 balance = _balances[address(this)];
        //获取当前余额,如果小于10枚不分
        if (balance < holderRewardCondition) {
            return;
        }
        IERC20 holdToken = IERC20(_mainPair); //获取池子
        uint holdTokenTotal = holdToken.totalSupply(); //获取总量lp
        uint delHoldTokenTotal =  excludeHolderNumber == 0 ? holdTokenTotal : holdTokenTotal - excludeHolderNumber;
        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;
        uint256 shareholderCount = holders.length; //获取持有人当前有多少
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
                amount = balance * tokenBalance / delHoldTokenTotal;
                if (amount > 0) {
                    _tokenTransfer(address(this),shareHolder,amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = block.number;
    }

    function isContract(address account) internal view returns (bool) {
            return account.code.length > 0;
    }

    //设置最小的分红
    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }
	function _isAddLiquidity()internal view returns(bool ldxAdd){

        address token0 = ISwapPair(address(_mainPair)).token0();
        address token1 = ISwapPair(address(_mainPair)).token1();
        (uint r0,uint r1,) = ISwapPair(address(_mainPair)).getReserves();
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
    //设置税
    function setFree(uint256 _free) external onlyOwner {
        free = _free;
    }
    //设置排除分红人
    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }
    //设置相关排除管理员的Lp数量
    function setExcludeHolderNumber(uint _excludeHolderNumber) external onlyOwner{
        excludeHolderNumber = _excludeHolderNumber;
    }

    //设置分红时间间隔块
    function setholdersBlock(uint256 _holdersBlock) external onlyOwner{
        holdersBlock = _holdersBlock;
    }
}

contract BBK is BBKToken {
    constructor() BBKToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        "BBK",
        "BBK",
        18,
        10000
    ){}
}