/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
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
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address private _owner;

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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    // function renounceOwnership() public virtual onlyOwner {
    //     emit OwnershipTransferred(_owner, address(0));
    //     _owner = address(0);
    // }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        // require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract AbsToken is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping (address => bool) isDividendExempt;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _updated;

    string private _name;//名称
    string private _symbol;//符号
    uint8 private _decimals;//精度

    uint256 public transferFee;//转账手续费
    uint256 public firstTransferFee;    //一周内转账手续费
    uint256 public projectFee;//给项目方

    address public mainPair;//主交易对地址

    mapping(address => bool) private _whiteList;//交易税白名单

    uint256 private constant MAX = ~uint256(0);

    uint256 private _tTotal;//总量

    ISwapRouter public _swapRouter;//dex swap 路由地址

    address public usdt;
    address public project1; //回流营销地址1
    address public project2;   //回流营销地址2

    uint256 public currentIndex;
    uint256 public distributorGas;
    uint256 public minPeriod;
    uint256 public LPFeefenhong;
    address public fromAddress;
    address public toAddress;
    uint256 public dayPeriod;

    address[] public shareholders;
    mapping (address => uint256) public shareholderIndexes;

    uint256 public dayReward;
    mapping (address => uint256) public distributeHolderTimes;

    bool public openAutoD = false;

    mapping(address => bool) private _distributeBlackList;

    uint256 public startTradeBlock; //开放交易的区块，用于杀机器人

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply){
    // function initParams(string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply) internal {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        projectFee = 2;
        transferFee = 6;
        firstTransferFee = 80;
        distributorGas = 500000;
        dayReward = 100 * 10**_decimals;

        // //mainnet
        // _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // usdt = address(0x55d398326f99059fF775485246999027B3197955);
        // project = address(0xFeA8a5BAF58c951370e66E2E68F9C752a05c5Ca3);
        // pool = address(0x13Ab08EE78fF83610320407613EBdB051b4Ed07A);
        // minPeriod = 1 hours;
        // dayPeriod = 23 hours;

         //testnet
        _swapRouter = ISwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        usdt = address(0x38C93854cB671bE1A23b2D9E86d892253EE4a725);
        project1 = address(0xce22Ec122bEc9b0199eB3cbc56E583665e58abF6);
        project2 = address(0x947362F59d9C9B993741525D7262Cf598541A895);
        minPeriod = 3 minutes;
        dayPeriod = 10 minutes;

        mainPair = ISwapFactory(_swapRouter.factory()).createPair(address(this), usdt);

        _tTotal = Supply * 10 ** _decimals;

        _balances[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);

        _whiteList[address(0x0)] = true;

        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
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

    function totalSupply() external view override returns (uint256) {
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
        require(amount <= _allowances[sender][msg.sender], 'allowed not enough');
        _transfer(sender, recipient, amount);
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        // require(amount < balanceOf(from), "from address balance not enough");

        bool takeFee = false;

        if (!_whiteList[from] && !_whiteList[to]) {
            takeFee = true;
        }
        if( from==mainPair || to==mainPair ){
            //交易未开启，只允许手续费白名单加池子，加池子即开放交易
            if (0 == startTradeBlock) {
                require(_whiteList[from] || _whiteList[to], "Trade not start");
                startTradeBlock = block.number;
            }
        }

        //买入
        if( from==mainPair && !_whiteList[from] && !_whiteList[to] ){
            if (startTradeBlock + 28800 <= block.number ) {  //开盘后一天内
                require( amount <= 2 * 1000 * 1000 * 10 ** _decimals, "limit in 2 millions");   //只能买入200万
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        // //distribute
        // if(fromAddress == address(0) )fromAddress = from;
        // if(toAddress == address(0) )toAddress = to;
        // if(!isDividendExempt[fromAddress] && fromAddress != mainPair ) setShare(fromAddress);
        // if(!isDividendExempt[toAddress] && toAddress != mainPair ) setShare(toAddress);

        // fromAddress = from;
        // toAddress = to;
        //  if(_balances[pool] >= dayReward && from !=address(this) && LPFeefenhong.add(minPeriod) <= block.timestamp && openAutoD) {
        //      process(distributorGas) ;
        //      LPFeefenhong = block.timestamp;
        // }
    }

    event NoShareHolder();
    event BalanceNotEough(uint256 _balance, uint256 _amount);
    event AmountTooSmall(uint256 _amount, uint256 _currentIndex, uint256 _iterations);

    event SetDistributeGas(uint256 oldValue, uint256 newValue);

    // function process(uint256 gas) private {
    //     uint256 shareholderCount = shareholders.length;

    //     if(shareholderCount == 0){
    //         return;
    //     }
    //     uint256 rewardAmount = 0;
    //     uint256 gasUsed = 0;
    //     uint256 gasLeft = gasleft();

    //     uint256 iterations = 0;

    //     IERC20 LP = IERC20(mainPair);

    //     while(gasUsed < gas && iterations < shareholderCount) {
    //         if(currentIndex >= shareholderCount){
    //             currentIndex = 0;
    //         }

    //         uint256 lpBalance = LP.balanceOf(shareholders[currentIndex]);
    //         if( lpBalance < 1 * 10**_decimals) {
    //             currentIndex++;
    //             iterations++;
    //             emit AmountTooSmall(lpBalance, currentIndex, iterations);
    //             continue;
    //         }
    //         uint256 amount = dayReward.mul(lpBalance).div(LP.totalSupply());
    //         if(_balances[pool]  < amount ){
    //             emit BalanceNotEough(_balances[pool], amount);
    //             break;
    //         }
    //         if( distributeHolderTimes[shareholders[currentIndex]] <= block.timestamp ){
    //             distributeDividend(shareholders[currentIndex],amount);
    //         }

    //         gasUsed = gasUsed.add(gasLeft.sub(gasleft()));

    //         gasLeft = gasleft();
    //         currentIndex++;
    //         iterations++;

    //         rewardAmount = rewardAmount.add( amount );

    //         if( rewardAmount>=dayReward ){
    //             break;   
    //         }
    //     }
    // }

    // function distributeDividend(address shareholder ,uint256 amount) internal {
    //     if( _distributeBlackList[shareholder] ){
    //         return;
    //     }

    //     _balances[pool] = _balances[pool].sub(amount);
    //     _balances[shareholder] = _balances[shareholder].add(amount);
    //     emit Transfer(pool, shareholder, amount);

    //     distributeHolderTimes[shareholder] = block.timestamp.add(dayPeriod);
    // }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender].sub(tAmount);

        uint256 feeAmount = 0;
        if (takeFee) {
            uint256 bai = uint256(100);

            if( sender==mainPair || recipient==mainPair ){  //属于买卖
                
                uint256 itemFeeAmount = tAmount.mul(projectFee).div(bai);
                _takeTransfer(sender, project1, itemFeeAmount);
                feeAmount = feeAmount.add(itemFeeAmount);
            }else if(sender!=mainPair){   //属于转账
                if (startTradeBlock + 28800*7 <= block.number ){ //开盘后一周内
                    
                    uint256 itemFeeAmount = tAmount.mul(firstTransferFee).div(bai);
                    _takeTransfer(sender, project2, itemFeeAmount);
                    feeAmount = feeAmount.add(itemFeeAmount);
                }else{
                  
                    uint256 itemFeeAmount = tAmount.mul(transferFee).div(bai);
                    _takeTransfer(sender, project2, itemFeeAmount);
                    feeAmount = feeAmount.add(itemFeeAmount);
                }
            }

            
        }

        tAmount = tAmount.sub(feeAmount);
        _takeTransfer(sender, recipient, tAmount);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to].add(tAmount);
        emit Transfer(sender, to, tAmount);
    }

    function setShare(address shareholder) private {
        if(_updated[shareholder] ){
            if(IERC20(mainPair).balanceOf(shareholder) == 0) quitShare(shareholder);
            return;
        }
        if(IERC20(mainPair).balanceOf(shareholder) == 0) return;
        addShareholder(shareholder);
        _updated[shareholder] = true;
    }
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
    function quitShare(address shareholder) private {
        removeShareholder(shareholder);
        _updated[shareholder] = false;
    }
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    function getUpdated(address _addr) public view returns(bool){
        return _updated[_addr];
    }
    function getShareholderCount() public view returns(uint256){
        return shareholders.length;
    }

    function switchOpenAutoD() external onlyOwner {
        if(openAutoD){
            openAutoD = false;
        }else{
            openAutoD = true;
        }
    }
    
    // function ownerDistribute() external onlyOwner {
    //     process(distributorGas);
    //     LPFeefenhong = block.timestamp;
    // } 

    function setDistributeBlackList(address addr) external onlyOwner {
        _distributeBlackList[addr] = true;
    }

    function removeDistributeBlackList(address addr) external onlyOwner {
        _distributeBlackList[addr] = false;
    }

    function isDistributeBlackList(address addr) external view returns (bool){
        return _distributeBlackList[addr];
    }

    function setDistributeGas(uint256 _gas) external onlyOwner {
        emit SetDistributeGas(distributorGas, _gas);
        distributorGas = _gas;
    }

    //设置白名单
    function setWhiteList(address addr) external onlyOwner {
        _whiteList[addr] = true;
    }

    //移除白名单
    function removeWhiteList(address addr) external onlyOwner {
        _whiteList[addr] = false;
    }
    //查看是否白名单
    function isWhiteList(address addr) external view returns (bool){
        return _whiteList[addr];
    }
}

contract HfToken is AbsToken {
    constructor() AbsToken(
        "HF1",
        "HF1",
        18,
        33 * 1000 * 1000
    ){
    }
}