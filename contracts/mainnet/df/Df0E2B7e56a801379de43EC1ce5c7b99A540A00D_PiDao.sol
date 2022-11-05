/**
 *Submitted for verification at BscScan.com on 2022-11-05
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

interface IPancakeRouter02 {
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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IPancakePair {
    function totalSupply() external view returns (uint);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function balanceOf(address owner) external view returns (uint);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface ISwapMining {
    function swap(address account, address input, address output, uint256 amount) external returns (bool);
}

interface IdoAddress {
    function getParentAddress(address account) external returns(address);
}
interface IWrap {
    function withdraw() external;
}

contract PiDao is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    IWrap public wrap = IWrap(0x591C965485b1357D1EebC8756995a00330Cb490B);
    
    mapping (address => uint256) private _rOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => uint256) public _rewardMapping;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 6660000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 public _pairValue;

    string private _name = "Pi Dao";
    string private _symbol = "PiDao";
    uint8 private _decimals = 18;
    
    uint256 public _jjSellFee = 20;
    uint256 public _burnSellFee = 0;
    uint256 public _lpSellFee = 20;
    uint256 public _nftSellFee = 40;
    
    uint256 public _invitBuyFee = 70;
    uint256 public _jjBuyFee = 10;
    
    uint256 public _transferFee = 80;
    

    address public ownerAddres;
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;
    address public jjAddress = 0x8BAD8553A52B5B343151f1A838F61589f9649d41;

    address public nftAddress = 0x85c2a05CdCFD4dEceBBcB29f7Ef08c2C8A8458f4;
    

    address public husdtToken = 0x55d398326f99059fF775485246999027B3197955;

    address public routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    IPancakeRouter02 public immutable uniswapV2Router;
    address public uniswapV2Pair;

    IdoAddress public idoAddress = IdoAddress(0x4C98E6Ce9DE6ca11D370dA935904Bf87B94F1425);

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
    uint256 public upRewardTime = block.timestamp;
    uint256 public rewardJg = 4 * 60;
    uint256 public rewardApr = 438;
    uint256 public rewardOneApr = 438;
    uint256 public rewardTwoApr = 352;
    uint256 public rewardThreeApr = 249;
    
    uint256 public rewardStarTime;
    uint256 public rewardOneDay = 270 days;
    uint256 public rewardTwoDay = 540 days;
    uint256 public rewardThreeDay = 720 days;


    uint256 public holdNumber = 3000 * 10 **18;

    uint256 private numTokensSellToAddToLiquidity = 300 * 10 **18;
    bool public rewardFlag = false;
    
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor ()  {
        ownerAddres = msg.sender;
        _rOwned[ownerAddres] = _rTotal;

        IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(routerAddress);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), husdtToken);

        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[ownerAddres] = true;
        _isExcludedFromFee[address(idoAddress)] = true;
        _isExcludedFromFee[burnAddress] = true;
        _isExcludedFromFee[jjAddress] = true;
        _isExcludedFromFee[nftAddress] = true;
        _isExcludedFromFee[address(this)] = true;
        
        emit Transfer(address(0),ownerAddres, _tTotal);
    }
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        if(from != ownerAddres && to != ownerAddres && _pairValue == 0) {
            require(to != uniswapV2Pair,"no start");
        }
        
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));

        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            to == uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount);
    }
    
    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        
        if (rewardFlag) {
            rewardSuper();
        }
        uint256 currentRate =  _getRate();
        bool _feeFlag = false;
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            _feeFlag = true;
        }
        if (sender == uniswapV2Pair) { 
            _pairValue = _pairValue.sub(amount);
            if (_feeFlag) {
                _rOwned[recipient] = _rOwned[recipient].add(amount.mul(currentRate));
                emit Transfer(sender,recipient, amount);
            } else {
                uint256 invitBuyAmount = amount.mul(_invitBuyFee).div(1000);
                uint256 jjBuyAmount = amount.mul(_jjBuyFee).div(1000);
                uint256 newAmount = amount.sub(invitBuyAmount).sub(jjBuyAmount);
                _rOwned[recipient] = _rOwned[recipient].add(newAmount.mul(currentRate));
                _rOwned[jjAddress] = _rOwned[jjAddress].add(jjBuyAmount.mul(currentRate));

                buyFeeDist(sender,recipient,invitBuyAmount);
                emit Transfer(sender,recipient, newAmount);
            }
        } else if (recipient == uniswapV2Pair) { 
            _rOwned[sender] = _rOwned[sender].sub(amount.mul(currentRate));
            if(_feeFlag) {
                _pairValue = _pairValue.add(amount);
                emit Transfer(sender,recipient, amount);
            } else {

                uint256 jjSellAmount = amount.mul(_jjSellFee).div(1000);
                uint256 burnSellAmount = amount.mul(_burnSellFee).div(1000);
                uint256 nftAmount = amount.mul(_nftSellFee).div(1000);
                uint256 lpSellAmount = amount.mul(_lpSellFee).div(1000);
                
                uint256 newAmount = amount.sub(jjSellAmount).sub(burnSellAmount).sub(nftAmount).sub(lpSellAmount);
                _pairValue = _pairValue.add(newAmount);
                sellFeeDist(jjSellAmount,burnSellAmount,nftAmount,lpSellAmount);
                emit Transfer(sender,recipient, newAmount);
            }
        } else {
            _rOwned[sender] = _rOwned[sender].sub(amount.mul(currentRate));
            if(_feeFlag) {
                _rOwned[recipient] = _rOwned[recipient].add(amount.mul(currentRate));
               emit Transfer(sender,recipient, amount);
            } else {
                uint256 tranferAmount = amount.mul(_transferFee).div(1000);
                uint256 newAmount = amount.sub(tranferAmount);
                _rOwned[recipient] = _rOwned[recipient].add(newAmount.mul(currentRate));
                _rOwned[jjAddress] = _rOwned[jjAddress].add(tranferAmount.mul(currentRate));
                emit Transfer(sender,recipient, newAmount);
            }
            
        }
        
    }
    
    function buyFeeDist(address sender,address recipient,uint256 invitBuyAmount) private {
        uint256 currentRate =  _getRate();
        uint256 oneAmount = invitBuyAmount.div(14);
        address sjAddress = idoAddress.getParentAddress(recipient);
        uint256 syAmount = invitBuyAmount;
        for (uint256 i=0; i < 10; i++) {
            if (sjAddress != address(0)) {
                uint256 newAmount = oneAmount;
                if (syAmount <= oneAmount) {
                    newAmount = syAmount;
                }
                if (i == 0) {
                    newAmount = oneAmount.mul(4);
                } else if(i == 1) {
                    newAmount = oneAmount.mul(2);
                }
                if (balanceOf(sjAddress) >= holdNumber) {
                    _rOwned[sjAddress] = _rOwned[sjAddress].add(newAmount.mul(currentRate));
                    _rewardMapping[sjAddress] = _rewardMapping[sjAddress].add(newAmount.mul(currentRate));
                    emit Transfer(sender,sjAddress, newAmount);
                    syAmount = syAmount.sub(newAmount);
                }
                
                sjAddress = idoAddress.getParentAddress(sjAddress);
            } else {
                _rOwned[jjAddress] = _rOwned[jjAddress].add(syAmount.mul(currentRate));
                break;
            }
        }
        
    }
    function setHoldNumber(uint256 _number) public onlyOwner {
        holdNumber = _number;
    }
    
    function sellFeeDist(uint256 jjSellAmount,uint256 burnSellAmount,uint256 nftAmount,uint256 lpSellAmount) private lockTheSwap {
        uint256 currentRate =  _getRate();
        if (burnSellAmount >= 0) {
            _rOwned[burnAddress] = _rOwned[burnAddress].add(burnSellAmount.mul(currentRate));
        }
        if (lpSellAmount >= 0) {
            _rOwned[address(this)] = _rOwned[address(this)].add(lpSellAmount.mul(currentRate));
        }
        if (jjSellAmount >= 0) {
            _rOwned[jjAddress] = _rOwned[jjAddress].add(jjSellAmount.mul(currentRate));
        }
        if (nftAmount >= 0) {
            _rOwned[nftAddress] = _rOwned[nftAddress].add(nftAmount.mul(currentRate));
        }
        
    }
    function getRate() external view returns(uint256){
        uint256 rate = 0;
        if (block.timestamp >= rewardStarTime.add(rewardThreeDay)) {
            return rate;
        } else if (block.timestamp >= rewardStarTime.add(rewardTwoDay)) {
            rate = rewardThreeApr;
        } else if (block.timestamp >= rewardStarTime.add(rewardOneDay)) {
            rate = rewardTwoApr;
        } else {
            rate = rewardOneApr;
        }
        return rate;
    }
    
    function rewardSuper() private {
        if (block.timestamp >= upRewardTime.add(rewardJg)) {
            if (block.timestamp >= rewardStarTime.add(rewardThreeDay)) {
                rewardFlag = false;
                return;
            } else if (block.timestamp >= rewardStarTime.add(rewardTwoDay)) {
                rewardApr = rewardThreeApr;
            } else if (block.timestamp >= rewardStarTime.add(rewardOneDay)) {
                rewardApr = rewardTwoApr;
            } else {
                rewardApr = rewardOneApr;
            }
            uint256 rewardValue = _tTotal.sub(_pairValue).mul(rewardApr).div(10000000);
            uint256 updateTime = block.timestamp.sub(upRewardTime);
            uint256 csNumber = updateTime.div(rewardJg);
            uint256 csValue = rewardValue.mul(csNumber);
            _tTotal = _tTotal.add(csValue);
            upRewardTime = upRewardTime.add(rewardJg.mul(csNumber));
        }
    }
    
    function setSellFee(uint256 jjFee,uint256 bFee,uint256 lpFee,uint256 nftFee) public onlyOwner {
        _jjSellFee = jjFee;
        _burnSellFee = bFee;
        _lpSellFee = lpFee;
        _nftSellFee = nftFee;
    }
    
    function setRewardDay(uint256 _oneDay,uint256 _twoDay,uint256 _threeDay) public onlyOwner {
        rewardOneDay = _oneDay;
        rewardTwoDay = _twoDay;
        rewardThreeDay = _threeDay;
    }
    
    function setRewardApr(uint256 _oneApr,uint256 _twoApr,uint256 _threeApr) public onlyOwner {
        rewardOneApr = _oneApr;
        rewardTwoApr = _twoApr;
        rewardThreeApr = _threeApr;
    }
    
    function setBuyFee(uint256 iFee,uint256 dFee) public onlyOwner {
        _invitBuyFee = iFee;
        _jjBuyFee = dFee;
    }
    
    function setJjAddress(address _new) public onlyOwner {
        jjAddress = _new;
        _isExcludedFromFee[address(_new)] = true;
    }
    
    function setNftAddress(address _new) public onlyOwner {
        nftAddress = _new;
        _isExcludedFromFee[address(_new)] = true;
    }
    
    function setIdoAddress(address _new) public onlyOwner {
        idoAddress = IdoAddress(_new);
        _isExcludedFromFee[address(_new)] = true;
    }
    
    function setNumTokensSellToAddToLiquidity(uint256 amount) public onlyOwner {
        numTokensSellToAddToLiquidity = amount;
    }
    
    function setWrap(IWrap _wrap) public onlyOwner {
        wrap = _wrap;
        _isExcludedFromFee[address(_wrap)] = true;
    }
    
    function setRewardFlag(bool _bool) public onlyOwner {
        rewardFlag = _bool;
        rewardStarTime = block.timestamp;
        upRewardTime = block.timestamp;
    }
    
    function setRewardApr(uint256 _rA) public onlyOwner {
        rewardApr = _rA;
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
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (account == uniswapV2Pair) {
            return _pairValue;
        } else {
            return tokenFromReflection(_rOwned[account]);
        }
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
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }
    
    function setExclude(address account,bool flag) public onlyOwner {
        _isExcludedFromFee[account] = flag;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
    receive() external payable {}
    
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
        uint256 initialBalance = IERC20(husdtToken).balanceOf(address(this));
        swapTokensForDividendToken(half);
        uint256 newBalance =IERC20(husdtToken).balanceOf(address(this)).sub(initialBalance);
        addLiquidity(otherHalf, newBalance);
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 tokenBmount) public {
        _approve(address(this), address(uniswapV2Router), tokenAmount * 100);
        IERC20(husdtToken).approve(address(uniswapV2Router), tokenBmount * 100);
        uniswapV2Router.addLiquidity (
            address(this),
            address(husdtToken),
            tokenAmount,
            tokenBmount,
            0,
            0,
            jjAddress,
            block.timestamp.add(30)
        );
    }
    
    function swapTokensForDividendToken(uint256 tokenAmount) private {
        if (tokenAmount > 0) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = husdtToken;
            
            _approve(address(this), address(uniswapV2Router), _tTotal);
    
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(wrap),
                block.timestamp.add(30)
            );
            wrap.withdraw();
        }  
    }
    
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}