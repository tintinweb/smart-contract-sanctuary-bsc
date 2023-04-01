/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

/**
 *Submitted for verification at BscScan.com on 2023-03-16
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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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

interface ISwapPair {
    function sync() external;
}

contract TokenDistributor {
    constructor (address token) {

        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => mapping(address => uint256)) private _allowances;

    
    address public fundAddress;
    
    address public fundAddress2;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public _buyInviteFee = 8;
  
    uint256 public _sellLPFee = 1;
 
    uint256 public _sellFundFee = 1;

    uint256 public _sellDestroyFee = 1;

    uint256 public _sellFundFee2 = 5;


    uint256 public startTradeBlock;

    mapping(address => bool) public _feeWhiteList;

    mapping(address => bool) public _excludeRewardList;

    uint256 public _tTotal;
    uint256 public _rTotal;
    mapping(address => uint256) public _rOwned;
    mapping(address => uint256) public _tOwned;
    uint256 public constant MAX = ~uint256(0);

    mapping(address => bool) public _swapPairList;

    uint256 public _limitAmount;

    uint256  public apr15Minutes = 25725;

    uint256 private constant AprDivBase = 100000000;

    uint256 public _lastRewardTime;
   
    bool public _autoApy;
 
    uint256 public _invitorHoldCondition;

  
    bool private inSwap;

    TokenDistributor public _tokenDistributor;
    address public _usdt;
    ISwapRouter public _swapRouter;

    constructor (address RouteAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceivedAddress, address FundAddress, address FundAddress2){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouteAddress);
        _swapRouter = swapRouter;
    
        _allowances[address(this)][address(swapRouter)] = MAX;

        _usdt = USDTAddress;
  
        address usdtPair = ISwapFactory(swapRouter.factory()).createPair(address(this), USDTAddress);
        _swapPairList[usdtPair] = true;
   
        _excludeRewardList[usdtPair] = true;


        uint256 tTotal = Supply * 10 ** Decimals;
        
        uint256 base = AprDivBase * 100;
      
        uint256 rTotal = MAX / base - (MAX / base % tTotal);
        _rOwned[ReceivedAddress] = rTotal;
        _tOwned[ReceivedAddress] = tTotal;
        emit Transfer(address(0), ReceivedAddress, tTotal);
        _rTotal = rTotal;
        _tTotal = tTotal;

        fundAddress = FundAddress;
        fundAddress2 = FundAddress2;

     
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[FundAddress2] = true;
        _feeWhiteList[ReceivedAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(swapRouter)] = true;

        _inProject[msg.sender] = true;

       
        _tokenDistributor = new TokenDistributor(USDTAddress);
    }

  
    function calApy() public {
   
        if (!_autoApy) {
            return;
        }
      
        uint256 total = _tTotal;
 
        uint256 maxTotal = _rTotal;
      
        if (total == maxTotal) {
            return;
        }
    
        uint256 blockTime = block.timestamp;
   
        uint256 lastRewardTime = _lastRewardTime;
      
        if (blockTime < lastRewardTime + 15 minutes) {
            return;
        }
       
        uint256 deltaTime = blockTime - lastRewardTime;
  
        uint256 times = deltaTime / 15 minutes;
       
        for (uint256 i; i < times;) {
           
            total = total * (AprDivBase + apr15Minutes) / AprDivBase;
           
            if (total > maxTotal) {
                total = maxTotal;
                break;
            }
           
        unchecked{
            ++i;
        }
        }
       
        _tTotal = total;
        
        _lastRewardTime = lastRewardTime + times * 15 minutes;
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
       
        if (_excludeRewardList[account]) {
            return _tOwned[account];
        }
        
        return tokenFromReflection(_rOwned[account]);
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

   
    function tokenFromReflection(uint256 rAmount) public view returns (uint256){
       
        uint256 currentRate = _getRate();
       
        return rAmount / currentRate;
    }

    function _getRate() public view returns (uint256) {
        
        if (_rTotal < _tTotal) {
            return 1;
        }
        
        return _rTotal / _tTotal;
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
       
        calApy();

        uint256 balance = balanceOf(from);
        
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        bool isBuy;

      
        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startTradeBlock) {
                
                require(_feeWhiteList[from] || _feeWhiteList[to], "!Trading");
               
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                
                if (block.number < startTradeBlock + 4) {
                    _funTransfer(from, to, amount);
                    return;
                }

                takeFee = true;
                if (_swapPairList[from]) {
                    isBuy = true;
                }
            }
        } else {
            
            if (0 == balanceOf(to) && amount > 0) {
                _bindInvitor(to, from);
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isBuy);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isBuy
    ) private {
      
        if (_tOwned[sender] > tAmount) {
            _tOwned[sender] -= tAmount;
        } else {
            _tOwned[sender] = 0;
        }

        
        uint256 currentRate = _getRate();
        
        _rOwned[sender] = _rOwned[sender] - tAmount * currentRate;

        uint256 feeAmount;
        if (takeFee) {
            if (isBuy) {
                uint256 totalInviteAmount = tAmount * _buyInviteFee / 100;
                feeAmount += totalInviteAmount;
                uint256 fundAmount = totalInviteAmount;
              
                if (totalInviteAmount > 0) {
                    address current = recipient;
                    address invitor;
                    uint256 inviterAmount;
                    uint256 perInviteAmount = totalInviteAmount / 16;
                    uint256 invitorHoldCondition = _invitorHoldCondition;
                    for (uint256 i; i < 10;) {
                        invitor = _inviter[current];
                        if (address(0) == invitor) {
                            break;
                        }
                        if (0 == i) {
                            inviterAmount = perInviteAmount * 6;
                        } else if (1 == i) {
                            inviterAmount = perInviteAmount * 2;
                        } else {
                            inviterAmount = perInviteAmount;
                        }
                        if (0 == invitorHoldCondition || balanceOf(invitor) >= invitorHoldCondition) {
                            fundAmount -= inviterAmount;
                            _takeTransfer(sender, invitor, inviterAmount, currentRate);
                        }
                        current = invitor;
                    unchecked{
                        ++i;
                    }
                    }
                }
                
                if (fundAmount > 1000000) {
                    _takeTransfer(sender, fundAddress, fundAmount, currentRate);
                }
            } else {
                if (!inSwap) {
                    inSwap = true;
                    
                    uint256 lpAmount = tAmount * _sellLPFee / 100;
                    if (lpAmount > 0) {
                        feeAmount += lpAmount;
                        _takeTransfer(
                            sender,
                            recipient,
                            lpAmount,
                            currentRate
                        );
                        ISwapPair(recipient).sync();
                    }
                    
                    uint256 fundFee = _sellFundFee + _sellFundFee2;
                    uint256 fundAmount = tAmount * fundFee / 100;
                    if (fundAmount > 0) {
                        feeAmount += fundAmount;
                        _takeTransfer(sender, address(this), fundAmount, currentRate);

                        address usdt = _usdt;
                        address tokenDistributor = address(_tokenDistributor);
                        address[] memory path = new address[](2);
                        path[0] = address(this);
                        path[1] = usdt;
                       
                        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                            fundAmount,
                            0,
                            path,
                            tokenDistributor,
                            block.timestamp
                        );

                        IERC20 USDT = IERC20(usdt);
                        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);
                        
                        uint256 fundUsdt = usdtBalance * _sellFundFee / fundFee;
                        if (fundUsdt > 0) {
                            USDT.transferFrom(tokenDistributor, fundAddress, fundUsdt);
                        }
                        uint256 fundUsdt1 = usdtBalance - fundUsdt;
                        if (fundUsdt1 > 0) {
                            USDT.transferFrom(tokenDistributor, fundAddress2, fundUsdt1);
                        }
                    }
                   
                    uint256 destroyAmount = tAmount * _sellDestroyFee / 100;
                    if (destroyAmount > 0) {
                        feeAmount += destroyAmount;
                        _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyAmount, currentRate);
                    }
                    inSwap = false;
                }
            }
        }

        _takeTransfer(
            sender,
            recipient,
            tAmount - feeAmount,
            currentRate
        );
    }

   
    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if (_tOwned[sender] > tAmount) {
            _tOwned[sender] -= tAmount;
        } else {
            _tOwned[sender] = 0;
        }

        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount * currentRate;
        _rOwned[sender] = _rOwned[sender] - rAmount;

        
        _takeTransfer(sender, fundAddress, tAmount / 100 * 90, currentRate);
      
        _takeTransfer(sender, recipient, tAmount / 100 * 10, currentRate);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        _tOwned[to] += tAmount;

        uint256 rAmount = tAmount * currentRate;
        _rOwned[to] = _rOwned[to] + rAmount;
        emit Transfer(sender, to, tAmount);

       
        if (_limitAmount > 0 && !_swapPairList[to] && !_feeWhiteList[to]) {
            require(_limitAmount >= balanceOf(to), "exceed LimitAmount");
        }
    }

    receive() external payable {}

    function claimBalance() external onlyFunder {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external onlyFunder {
        IERC20(token).transfer(fundAddress, amount);
    }

    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundAddress2(address addr) external onlyFunder {
        fundAddress2 = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
        if (enable) {
            _excludeRewardList[addr] = true;
        }
    }

    
    function setExcludeReward(address addr, bool enable) external onlyFunder {
        _tOwned[addr] = balanceOf(addr);
        _rOwned[addr] = _tOwned[addr] * _getRate();
        _excludeRewardList[addr] = enable;
    }

    function setBuyFee(uint256 buyInviteFee) external onlyOwner {
        _buyInviteFee = buyInviteFee;
    }

    function setSellFee(uint256 sellLPFee, uint256 sellFundFee, uint256 sellDestroyFee, uint256 sellFundFee2) external onlyOwner {
        _sellLPFee = sellLPFee;
        _sellFundFee = sellFundFee;
        _sellDestroyFee = sellDestroyFee;
        _sellFundFee2 = sellFundFee2;
    }

    
    function setLimitAmount(uint256 amount) external onlyFunder {
        _limitAmount = amount * 10 ** _decimals;
    }



   
    function startAutoApy() external onlyFunder {
        require(!_autoApy, "autoAping");
        _autoApy = true;
        _lastRewardTime = block.timestamp;
    }

   
    function emergencyCloseAutoApy() external onlyFunder {
        _autoApy = false;
    }

    
    function closeAutoApy() external onlyFunder {
        calApy();
        _autoApy = false;
    }

   
    function setApr15Minutes(uint256 apr) external onlyFunder {
        calApy();
        apr15Minutes = apr;
    }

    function setInvitorHoldCondition(uint256 amount) external onlyFunder {
        _invitorHoldCondition = amount * 10 ** _decimals;
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }

    mapping(address => address) public _inviter;
    mapping(address => address[]) private _binders;
    mapping(address => bool) public _inProject;

    
    function bindInvitor(address account, address invitor) public {
        address caller = msg.sender;
        require(_inProject[caller], "notInProj");
        _bindInvitor(account, invitor);
    }

    
    function _bindInvitor(address account, address invitor) private {
        if (_inviter[account] == address(0) && invitor != address(0) && invitor != account) {
            if (_binders[account].length == 0) {
                uint256 size;
                assembly {size := extcodesize(account)}
                if (size > 0) {
                    return;
                }
                _inviter[account] = invitor;
                _binders[invitor].push(account);
            }
        }
    }

    function setInProject(address adr, bool enable) external onlyFunder {
        _inProject[adr] = enable;
    }
}

contract AGI is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
 
        "Artificial general intelligence",
   
        "AGI",
   
        6,
    
        2000000000000000,
    
        address(0xC070Ec7a2495D911248D1687Ebd809c47518C8b7),
    
        address(0xC070Ec7a2495D911248D1687Ebd809c47518C8b7),
    
        address(0xC070Ec7a2495D911248D1687Ebd809c47518C8b7)
    ){

    }
}