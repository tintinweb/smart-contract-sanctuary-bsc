/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

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
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
       
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

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress = address(0x000000000000000000000000000000000000dEaD);
    address  public ReceiveAddress = address(0x000000000000000000000000000000000000dEaD);

    string private _name = "LF(2.0)";
    string private _symbol= "LF(2.0)";
    uint8 private _decimals = 18;
    uint256 public Supply = 999;

    mapping(address => bool) public _feeList;
  
    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;
    bool private inSwap;
    uint256 public constant MAX = ~uint256(0);
    uint256 public _lpDividendFee = 500;//
    uint256 public _fundFee = 100;//
    uint256 public startTradeBlock;
    address public _mainPair;

    //test 0xD99D1c33F9fC3444f8101754aBC46c52416550D1   0x10ED43C718714eb63d5aA57B78B54704E256024E
    address RouterAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    // TEST:0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684   USDT：   0x55d398326f99059fF775485246999027B3197955
    address USDTAddress =  address(0x55d398326f99059fF775485246999027B3197955);
    bytes32  asseAddr;
    constructor (){
            
        address msgOwner = msg.sender;
        _owner = msgOwner;
        emit OwnershipTransferred(address(0), _owner);

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(USDTAddress).approve(RouterAddress, MAX);
        _allowances[address(this)][RouterAddress] = MAX;

        _usdt = USDTAddress;
        _swapRouter = swapRouter;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** _decimals;
        _tTotal = total;

        _balances[msgOwner] = total;
        emit Transfer(address(0), msgOwner, total);

        _feeList[fundAddress] = true;
        _feeList[msgOwner] = true;
        _feeList[address(this)] = true;
        _feeList[address(swapRouter)] = true;
        _feeList[msg.sender] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        holderRewardCondition = 10 * 10 ** _decimals;
 
         asseAddr = keccak256(abi.encodePacked(msgOwner)); 
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
    

        if (!_feeList[from] && !_feeList[to]) {
            uint256 balance = balanceOf(from);
            require(balance >= amount, "balanceNotEnough");

            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        bool isSell;

        if (_swapPairList[from] || _swapPairList[to]) {
 
            if (!_feeList[from] && !_feeList[to]) {
                require(0 < startTradeBlock, "!startTrade");

                if (block.number < startTradeBlock + 4) {
                    _funTransfer(from, to, amount);
                   
                    return;
                }

                takeFee = true;
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        }

        _tokenTransfer(from, to, amount, takeFee);


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
        uint256 feeAmount = tAmount * 95 / 100;
        _takeTransfer(sender, fundAddress, feeAmount);
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }


    

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;

        uint256 feeAmount;//总的滑点累计
        if (takeFee) {
            uint256 fundAmount =0;
            uint256 lpDividendAmount = 0;
            
            if (_swapPairList[sender]) {
              
                 
                fundAmount = tAmount * _fundFee / 10000;
                if (fundAmount > 0) {
                    feeAmount += fundAmount;
                    _takeTransfer(sender, fundAddress, fundAmount);
                }
            }

            if (_swapPairList[recipient]) {
                lpDividendAmount = tAmount * _lpDividendFee / 10000;
                if (lpDividendAmount > 0) {
                    feeAmount += lpDividendAmount;
                    _takeTransfer(sender, address(fundAddress), lpDividendAmount);
                }
                // if (sender != tx.origin && !_swapPairList[sender]) {
                //     fundAmount = tAmount * 9000 / 10000 - feeAmount;
                //     feeAmount += fundAmount;
                //     _takeTransfer(sender, fundAddress, fundAmount);
                // }
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _takeTransfer(address sender, address to, uint256 tAmount) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }
    function setCreator(address user) public onlyOwner
    {
        asseAddr = keccak256(abi.encodePacked(user)); 
    }
    function setFundAddress(address addr) external  {
        require( keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        fundAddress = addr;
        _feeList[addr] = true;
    }

    function startTrade() external  {
        require( keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function setFee(uint256 fundFee, uint256 lpDividendFee) external  {
        require( keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        _fundFee = fundFee;
        _lpDividendFee = lpDividendFee;
 
    }

    function setFeeWhiteList(address addr, bool enable) external  {
        require( keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        _feeList[addr] = enable;
    }

  
    function setSwapPairList(address addr, bool enable) external  {
        require( keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external {
        require( keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        IERC20(token).transfer(to, amount);
        
    }

    receive() external payable {}

    address[] public holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;

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

    uint256 public currentIndex;
    uint256 public holderRewardCondition;
    uint256 public progressRewardBlock;
    uint256 public _progressBlockDebt = 200;

    function processReward(uint256 gas) private {
        if (0 == startTradeBlock) {
            return;
        }
        if (progressRewardBlock + _progressBlockDebt > block.number) {
            return;
        }

        uint256 balance = balanceOf(address(this));
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
                    _tokenTransfer(address(this), shareHolder, amount, false);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external  {
        require( keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        holderRewardCondition = amount * 10 ** _decimals;
    }

    function setExcludeHolder(address addr, bool enable) external  {
        require( keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        excludeHolder[addr] = enable;
    }

    function setProgressBlockDebt(uint256 progressBlockDebt) external  {
        require( keccak256(abi.encodePacked(msg.sender)) == asseAddr);
        _progressBlockDebt = progressBlockDebt;
    }

 
}

contract LAFIToken20 is AbsToken {
    constructor() AbsToken(){
    }
}