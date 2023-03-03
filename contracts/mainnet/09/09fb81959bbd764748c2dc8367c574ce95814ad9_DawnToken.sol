/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
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
    function sub(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface ISwapRouter {
    function factory() external pure returns (address);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external;
}
interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract DawnToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    string private _name = "DAWN";
    string private _symbol = "DAWN";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 100000000 * 10**18;
    address public marketAddr1 = 0xFCE5007E7D5f144fe9183C77F68f45f0A18f1Cfd;//PRO 营销钱包地址
    address public marketAddr2 = 0x0a98906804c85040F8AA829a6596D0bFA8Ff7F69;//PRO 营销钱包地址
    address public manageAddr = 0xA11f8EFdDC5770C115290b769DD13B426c4a093A;//PRO 管理地址
    address public usdtAddr = 0x55d398326f99059fF775485246999027B3197955;//PRO
    address public routerAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;//PRO
    ISwapRouter public swapRouter;
    address public lpAddr;

    uint256 public swapMinAcc = 5 * 10**18;//最小累积token数，累积超过这个阀值就开始卖出
    bool public swapByMin = true;//强制每次卖出最小值swapMinAcc数量的token,为false时，卖出累积的全部token
    bool public excLock = false;//交易开关
    mapping(address => bool) public whiteList;//手续费白名单，不收手续费
    mapping(address => bool) public blackList;//转账黑名单，限制转入和转出
    uint256[] public feeRate = [5,15,60,920];//加起来等于1000
    
    constructor () {
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);

        swapRouter = ISwapRouter(routerAddr);
        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        lpAddr = swapFactory.createPair(address(this), usdtAddr);

        whiteList[address(this)] = true;
        whiteList[address(routerAddr)] = true;
        whiteList[msg.sender] = true;
        whiteList[marketAddr1] = true;
        whiteList[marketAddr2] = true;
    }

    receive() external payable {}

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
 
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
  
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender,_msgSender(), currentAllowance.sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(!blackList[sender] && !blackList[recipient],"in the blacklist");//如果在黑名单，限制转入 和 转出

        uint256 realGetAmount = amount;
        if(lpAddr == sender || lpAddr == recipient){
            //交易池锁状态
            require(!excLock, "swap is locked");

            //如果不在白名单，则扣手续费
            if((lpAddr == sender && !whiteList[recipient]) || (lpAddr == recipient && !whiteList[sender])){
                if(feeRate[0] > 0){
                    uint256 desAmount = amount.mul(feeRate[0]).div(1000);
                    _balances[address(0)] = _balances[address(0)].add(desAmount);
                    emit Transfer(sender, address(0), desAmount);
                }
                
                if(feeRate[1] > 0){
                    uint256 feeAmount = amount.mul(feeRate[1]).div(1000);
                    _balances[marketAddr2] = _balances[marketAddr2].add(feeAmount);
                    emit Transfer(sender, marketAddr2, feeAmount);
                }
                
                if(feeRate[2] > 0){
                    uint256 excAmount = amount.mul(feeRate[2]).div(1000);
                    _balances[address(this)] = _balances[address(this)].add(excAmount);
                    emit Transfer(sender, address(this), excAmount);
                }

                realGetAmount=amount.mul(feeRate[3]).div(1000);
            }

            //如果是卖出，则触发换U
            if(lpAddr != sender && lpAddr == recipient ){
                uint256 allAmount = balanceOf(address(this));
                if (allAmount > swapMinAcc) {
                    address[] memory path = new address[](2);
                    path[0] = address(this);
                    path[1] = usdtAddr;
                    uint256 curSell = swapByMin?swapMinAcc:allAmount;
                    //卖出 DAWN 换 USDT
                    _approve(address(this), address(swapRouter), curSell);
                    swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(curSell,0,path,address(marketAddr1),block.timestamp);
                }
            }
        }
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(realGetAmount);
        emit Transfer(sender, recipient, realGetAmount);
    }

    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _balances[address(0)] = _balances[address(0)].add(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setExcLock(bool _excLock) public onlyOwner {
        excLock = _excLock;
    }

    function setBlackList(address[] memory addrList,bool isIn) public onlyOwner {
        require(addrList.length > 0  && addrList.length <= 50);
        for (uint256 i; i < addrList.length; ++i) {
            blackList[addrList[i]] = isIn;
        }
    }

    function setSwap(uint256 _swapMinAcc,bool _swapByMin) public onlyOwner {
        swapMinAcc = _swapMinAcc;
        swapByMin = _swapByMin;
    }

    //另外账号，只能修改：滑点 白名单
    modifier onlyManage() {
        require(owner() == msg.sender || manageAddr == msg.sender, "!manage");
        _;
    }

    function setWhiteList(address[] memory addrList,bool isIn) public onlyManage {
        require(addrList.length > 0  && addrList.length <= 50);
        for (uint256 i; i < addrList.length; ++i) {
            whiteList[addrList[i]] = isIn;
        }
    }

    function setFeeRate(uint256[] memory _feeRate) public onlyManage{
        require(_feeRate.length == 4 && (_feeRate[0]+_feeRate[1]+_feeRate[2]+_feeRate[3]) == 1000);
        feeRate = _feeRate;
    }
}