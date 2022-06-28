/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;
interface IBEP20 {
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}
abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}
interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
contract DDAO is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    string private _name = "Dimensional Dao";
    string private _symbol = "DDAO";
    uint8 private _decimals = 9;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _isExcludedFromFee;
    mapping (address => bool) public _isLPHolderExist;
    mapping (address => address) public _inviter;
    
    uint256 private MAX = ~uint256(0);
    uint256 private _tTotal = 10000000*(1e9);
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tSupply = 100000*(1e9);

    uint256 public buyFeeOfLPDifidend = 4;
    uint256 public buyFeeOfMarketing = 2;
    uint256 public buyFeeOfReferrer = 2;

    uint256 public sellFeeOfLPDifidend = 3;
    uint256 public sellFeeOfHoldDifidend = 2;
    uint256 public sellFeeOfBurn = 5;

    uint256 public feeOfTransfer = 15;

    uint256 public minLpDifidendAmount = 1000*(1e9);
    uint256 public timeOfLiquidityAdded;
    bool private isLiquidityAdded;
    address public pair;
    address public minter;
    address private virtualMinter;
    address public usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
    address public marketingAddress = 0x0CF58eAaC3DAb64f9CE8c6c0b621f0BA37555555;
    address public DEAD = 0x000000000000000000000000000000000000dEaD;
    address private lastPotentialLPHolder;
    address[] public lpHolders;
    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }
    constructor () {
        uint256 _rate = _rTotal.div(_tTotal);
        _rOwned[tx.origin] = _tSupply.mul(_rate);
        _tOwned[virtualMinter] = _tTotal.sub(_tSupply);
        _rOwned[virtualMinter] = _tOwned[virtualMinter].mul(_rate);
        IPancakeRouter02 _router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IPancakeFactory(_router.factory()).createPair(address(this), usdtAddress);
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[marketingAddress] = true;
        emit Transfer(address(0), _msgSender(), _tSupply);
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view override returns (uint256) {
        return _tSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        if(account == virtualMinter) return 0;
        return tokenFromReflection(_rOwned[account]);
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function mint(address account, uint256 tAmount) external returns (bool){
        require(_msgSender() == minter, "not minter called");
        require(account != address(0), "zero address");
        require(tAmount > 0, "invalid amount");
        uint256 rAmount = tAmount.mul(_getRate());
        _rOwned[account] = _rOwned[account].add(rAmount);
        _tSupply = _tSupply.add(tAmount);
        uint256 _tDEAD = _rOwned[DEAD].div(_getRate());
        require(_tSupply <= _tTotal.sub(_tDEAD), "max supply is _tTotal");
        _rOwned[virtualMinter] = _rOwned[virtualMinter].sub(rAmount);
        _tOwned[virtualMinter] = _tOwned[virtualMinter].sub(tAmount);
        emit Transfer(address(0), account, tAmount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        return rAmount.div(_getRate());
    }
    function excludeFromFee(address[] memory accounts) public onlyOwner {
        require(accounts.length > 0, "no account");
        for(uint8 i = 0; i < accounts.length; i++){
            if(_isExcludedFromFee[accounts[i]] == false){
                _isExcludedFromFee[accounts[i]] = true;
            }      
        }
    }
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    function setBuyFeeOfLPDifidend(uint256 value) external onlyOwner() {
        buyFeeOfLPDifidend = value;
    }
    function setBuyFeeOfMarketing(uint256 value) external onlyOwner() {
        buyFeeOfMarketing = value;
    }
    function setBuyFeeOfReferrer(uint256 value) external onlyOwner() {
        buyFeeOfReferrer = value;
    }
    function setSellFeeOfLPDifidend(uint256 value) external onlyOwner() {
        sellFeeOfLPDifidend = value;
    }
    function setSellFeeOfHoldDifidend(uint256 value) external onlyOwner() {
        sellFeeOfHoldDifidend = value;
    }
    function setSellFeeOfBurn(uint256 value) external onlyOwner() {
        sellFeeOfBurn = value;
    }
    function setFeeOfTransfer(uint256 value) external onlyOwner() {
        feeOfTransfer = value;
    }
    function setMinLpDifidendAmount(uint256 value) external onlyOwner() {
        minLpDifidendAmount = value*(1e9);
    }
    function setMinter(address _minter) external onlyOwner() {
        minter = _minter;
    }
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _getRate() public view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }
    function _getCurrentSupply() private view returns(uint256, uint256) {
        if (_rOwned[virtualMinter] > _rTotal || _tOwned[virtualMinter] > _tTotal) return (_rTotal, _tTotal);
        uint256 rSupply = _rTotal.sub(_rOwned[virtualMinter]);
        uint256 tSupply = _tTotal.sub(_tOwned[virtualMinter]);
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if(from != pair && to != pair && _rOwned[to] == 0 && _inviter[to] == address(0)) {
            _inviter[to] = from;
        }
        if(!isLiquidityAdded && to == pair) {
            timeOfLiquidityAdded = block.timestamp;
            isLiquidityAdded = true;
            lpHolders.push(from);
            _isLPHolderExist[from] = true;
        }
        uint256 _rAmount = amount.mul(_getRate());
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            _rOwned[from] = _rOwned[from].sub(_rAmount);
            _rOwned[to] = _rOwned[to].add(_rAmount);
            emit Transfer(from, to, amount); 
        } else {
            _tokenTransferWithFee(from,to,_rAmount);
        }  
        if(lastPotentialLPHolder != address(0) && !_isLPHolderExist[lastPotentialLPHolder]) {
            uint256 lpAmount = IBEP20(pair).balanceOf(lastPotentialLPHolder);
            if(lpAmount > 0) {
                lpHolders.push(lastPotentialLPHolder);
                _isLPHolderExist[lastPotentialLPHolder] = true;
            }
        }
        if(to == pair) {
            lastPotentialLPHolder = from;
        }
        uint256 contractTokenBalance = balanceOf(address(this));
        if (contractTokenBalance >= minLpDifidendAmount && unlocked == 1) {
            _difidendToLPHolders();
        }
    }
    function _tokenTransferWithFee(address sender, address recipient, uint256 rAmount) private {
        if(recipient == pair && rAmount > _rOwned[sender].div(10000).mul(9999)) {
            rAmount = _rOwned[sender].div(10000).mul(9999);
        }
        uint256 totalFee = 0;
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        if(sender == pair) {//buy
            uint256 feeOfLPDifidend = rAmount.mul(buyFeeOfLPDifidend).div(100);
            if(feeOfLPDifidend > 0) {
                _rOwned[address(this)] = _rOwned[address(this)].add(feeOfLPDifidend);
                emit Transfer(sender, address(this), feeOfLPDifidend.div(_getRate()));
            }
            uint256 feeOfMarketing = rAmount.mul(buyFeeOfMarketing).div(100);
            if(feeOfMarketing > 0) {
                _rOwned[marketingAddress] = _rOwned[marketingAddress].add(feeOfMarketing);
                emit Transfer(sender, marketingAddress, feeOfMarketing.div(_getRate()));
            }
            address inviter = _inviter[recipient];
            address to;
            if( inviter != address(0)) {
               to = inviter; 
            } else {
               to = marketingAddress;
            }
            uint256 feeOfInviter = rAmount.mul(buyFeeOfReferrer).div(100);
            if(feeOfInviter > 0) {
                _rOwned[to] = _rOwned[to].add(feeOfInviter);
                emit Transfer(sender, to, feeOfInviter.div(_getRate()));
            } 
            totalFee = feeOfLPDifidend.add(feeOfMarketing).add(feeOfInviter);
        } else if(recipient == pair) {  //sell or addliquidity
            uint256 feeOfLPDifidend = rAmount.mul(sellFeeOfLPDifidend).div(100);
            if(feeOfLPDifidend > 0) {
                _rOwned[address(this)] = _rOwned[address(this)].add(feeOfLPDifidend);
                emit Transfer(sender, address(this), feeOfLPDifidend.div(_getRate()));
            }
            uint256 feeOfHoldDifidend = rAmount.mul(sellFeeOfHoldDifidend).div(100);
            if(feeOfHoldDifidend > 0) {
                _rTotal = _rTotal.sub(feeOfHoldDifidend);
            }
            uint256 feeOfBurn = rAmount.mul(sellFeeOfBurn).div(100);
            if(feeOfBurn > 0) {
                _rOwned[DEAD] = _rOwned[DEAD].add(feeOfBurn);
                _tSupply = _tSupply.sub(feeOfBurn.div(_getRate()));
                emit Transfer(sender, DEAD, feeOfBurn.div(_getRate()));
            }
            totalFee = feeOfLPDifidend.add(feeOfHoldDifidend).add(feeOfBurn);
        } else { //transfer
            uint256 feeOfBurn = rAmount.mul(feeOfTransfer).div(100);
            if(feeOfBurn > 0) {
                _rOwned[DEAD] = _rOwned[DEAD].add(feeOfBurn);
                _tSupply = _tSupply.sub(feeOfBurn.div(_getRate()));
                emit Transfer(sender, DEAD, feeOfBurn.div(_getRate()));
            }
            totalFee = feeOfBurn;
        }
        if (recipient == pair || sender == pair ){
            if (block.timestamp <= timeOfLiquidityAdded + 6){
                uint256 robotFee = rAmount.mul(60).div(100);
                _rOwned[DEAD] = _rOwned[DEAD].add(robotFee);
                _tSupply = _tSupply.sub(robotFee.div(_getRate()));
                emit Transfer(sender, DEAD, robotFee.div(_getRate()));
                totalFee = totalFee.add(robotFee);
            }
        }
        _rOwned[recipient] = _rOwned[recipient].add(rAmount.sub(totalFee));
        emit Transfer(sender, recipient, (rAmount.sub(totalFee)).div(_getRate()));
    }
    function _difidendToLPHolders() private lock {
        IBEP20 pairContract = IBEP20(pair);
        uint256 amount = _rOwned[address(this)];
        uint256 totalLPAmount = pairContract.totalSupply() - 1e3;
        address cur;
        uint256 temp = 0;
        for(uint256 i = 0; i < lpHolders.length; i++){
            cur = lpHolders[i];
            uint256 LPAmount = pairContract.balanceOf(cur);
            if(LPAmount > 0) {
                uint256 difidendAmount = amount.div(totalLPAmount).mul(LPAmount);
                if(difidendAmount == 0) { continue; }
                _rOwned[cur] = _rOwned[cur].add(difidendAmount);
                temp = temp.add(difidendAmount);
                emit Transfer(address(this), cur, difidendAmount.div(_getRate()));
            }
        }
        _rOwned[address(this)] = _rOwned[address(this)].sub(temp);
    }
    function excludeFromLPHolders(address account) public onlyOwner() {
        require(_isLPHolderExist[account], "Account is already excluded");
        for (uint256 i = 0; i < lpHolders.length; i++) {
            if (lpHolders[i] == account) {
                lpHolders[i] = lpHolders[lpHolders.length - 1];
                _isLPHolderExist[account] = false;
                lpHolders.pop();
                break;
            }
        }
    }
}