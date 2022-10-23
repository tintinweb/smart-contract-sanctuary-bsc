/**
 *Submitted for verification at BscScan.com on 2022-10-23
*/

pragma solidity 0.8.13;
// SPDX-License-Identifier: MIT
// https://fairtoken.info

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ProcessingRouter {
    function addToLottery(address _tokenAddress, uint256 _amount) external returns(bool);
    function addToLotteryAfterSwap(address _tokenAddress) external returns(bool);
    function addToClaimable(address _tokenAddress, uint256 _amount) external returns(bool);
    function addToClaimableAfterSwap(address _tokenAddress) external returns(bool);
    function claim(address account) external;
}

interface PancakeSwapFactoryV2 {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface PancakeSwapRouterV2 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function factory() external pure returns (address);
    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
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
    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) 
        external 
        returns (uint256[] memory amounts);
}

library SafeMath {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
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

contract FAIRTOKEN is Ownable {
    using SafeMath for uint256;
    string public name = "FairToken";
    string public symbol = "FRT";
    uint256 public totalSupply = 1000000000e18;
    uint256 private dividendTokens = 0;
    uint8 public decimals = 18;
    uint256 public deadBlocks = 2;
    bool public isTradingEnabled = false;
    bool public lockIsEnabled = true;
    bool public lotteryIsEnabled = true;
    bool public antibot = true;
    uint256 private startBlock;
    uint256 public burnFee = 500; // 5% OR M
    uint256 public marketingFee = 500; // 5% OR B
    uint256 public lotteryFee = 500; // 5%
    uint256 public holderFee = 1000; // 10%
    uint256 public buyLimitLiquidity = 100; // 1%
    uint256 public blockTimeout = 10; // Blocks transaction interval for user
    uint256 public maxTxAmount = totalSupply;
    uint256 public lockReleaseTime = 259200; // 259200
    uint256 public lockReleasePercent = 1000; // 10%
    uint public holders;
    PancakeSwapRouterV2 private _pancakeRouterV2 = PancakeSwapRouterV2(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public _dead = 0x000000000000000000000000000000000000dEaD;
    address public _marketing = 0x41ACf4c87319b48b85aC41bb577D57FF7976fbCc;
    ProcessingRouter private _processingRouter = ProcessingRouter(0x0000000000000000000000000000000000000000);
    IERC20 private _busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address public pair;

    event Unlock(address indexed _from, uint256 _value);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    struct lockStructure {
        uint256 startLockTimestamp;
        uint256 unlockInterval;
        uint256 unlocksNum;
        uint256 percentUnlock;
        uint256 allLockedAmount;
        uint256 countUnlocks;
        uint256 UnLockedAmount;
    }

    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public lockedBalanceOf;
    mapping(address => uint256) public userUnlocks;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isBlacklisted;
    mapping(address => bool) public isWhitelisted;
    mapping(address => bool) public isDisabledFee;
    mapping(address => bool) public isDisabledDividends;
    mapping(uint256 => address) public HolderList;
    mapping(address => uint256) public HolderID;
    mapping(address => uint256) public lastTransfer;
    mapping(address => lockStructure[]) userLockList;

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        isWhitelisted[msg.sender] = true;
        isWhitelisted[address(this)] = true;
        isWhitelisted[_marketing] = true;
        isDisabledDividends[address(this)] = true;
        isDisabledDividends[_dead] = true;
        isDisabledDividends[msg.sender] = true;
        HolderList[holders] = msg.sender;
        HolderID[msg.sender] = holders;
        holders++;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function _burn(address _from, uint256 _amount) internal returns (bool success) {
        _checkDividends(_from, _dead, _amount);
        balanceOf[_from] -= _amount;
        balanceOf[_dead] += _amount;
        emit Transfer(_from, _dead, _amount);
        return true;
    }

    function _toMarketing(address _from, uint256 _amount) private returns (bool success) {
        _checkDividends(_from, _marketing, _amount);
        balanceOf[_from] -= _amount;
        balanceOf[_marketing] += _amount;
        emit Transfer(_from, _marketing, _amount);
        return true;
    }
    function _toTokenAddress(address _from, uint256 _amount) private returns (bool success) {
        _checkDividends(_from, address(this), _amount);
        balanceOf[_from] -= _amount;
        balanceOf[address(this)] += _amount;
        emit Transfer(_from, address(this), _amount);
        return true;
    }
    function _toProcessing(address _from, uint256 _amount) private returns (bool success) {
        _checkDividends(_from, address(_processingRouter), _amount);
        balanceOf[_from] -= _amount;
        balanceOf[address(_processingRouter)] += _amount;
        emit Transfer(_from, address(_processingRouter), _amount);
        return true;
    }
    function _toSwapAndProcessing(address _from, uint256 _amount) private returns (bool success) {
        if(address(_processingRouter) == address(0)) return false;
        _toTokenAddress(_from, _amount);
        swapTokenForBusd(_amount, address(_processingRouter));
        return true;
    }
    function _getPathForSwap() private view returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = address(_busd);
    return path;
    }
    function swapTokenForBusd(uint256 _amount, address _to) private returns(bool) {
    _pancakeRouterV2.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                       _amount,
                       0,
                       _getPathForSwap(),
                       _to,
                       block.timestamp
                       );
     return true;
    }
    function _toProcessingClaimable(address _from, uint256 _amount) private returns (bool success) {
        if(address(_processingRouter) == address(0)) return false;
        _toProcessing(_from, _amount);
        _processingRouter.addToClaimable(address(this), _amount);
        return true;
    }
    function _toSwapAndProcessingClaimable(address _from, uint256 _amount) private returns (bool success) {
        if(address(_processingRouter) == address(0)) return false;
        _toSwapAndProcessing(_from, _amount);
        _processingRouter.addToClaimableAfterSwap(address(_busd));
        return true;
    }

    function _toProcessingLottery(address _from, uint256 _amount) private returns (bool success) {
        if(address(_processingRouter) == address(0)) return false;
        _toProcessing(_from, _amount);
        _processingRouter.addToLottery(address(this), _amount);
        return true;
    }
    function _toSwapAndProcessingLottery(address _from, uint256 _amount) private returns (bool success) {
        if(address(_processingRouter) == address(0)) return false;
        _toSwapAndProcessing(_from, _amount);
        _processingRouter.addToLotteryAfterSwap(address(_busd));
        return true;
    }
    function getTokenPricePair(uint256 _amount) public view returns (uint256 _tokenPrice) {
        if(pair == address(0)) return 0;
         uint256[] memory price = _pancakeRouterV2.getAmountsOut(_amount, _getPathForSwap());
      return price[price.length-1];
    }
    function getLiquidity() public view returns (uint256[] memory) {
    uint256[] memory liquidity = new uint256[](2);
    if(pair == address(0)) {
    liquidity[0] = 0;
    liquidity[1] = 0;
    } else {
    liquidity[0] = balanceOf[pair];
    liquidity[1] = _busd.balanceOf(pair);
    }
    return liquidity;
    }
    function checkBuylimitLiquidity() public view returns (uint256 _limitVal) {
        if(pair == address(0))  return totalSupply;
        if(buyLimitLiquidity == 0)  return totalSupply;
         uint256 tokenLiquidity = balanceOf[pair];
         uint256 buyLimitLiq = tokenLiquidity.mul(buyLimitLiquidity).div(10000);
      return buyLimitLiq;
    }
    function storeLocker(address _to, uint256 holdTimeInterval, uint256 _percentUnlock, uint256 _amount) internal returns (bool success) {
        uint256 _unlocksNum = uint256(100).mul(_percentUnlock).div(10000);
        lockStructure memory lockstructure = lockStructure(block.timestamp, holdTimeInterval, _unlocksNum, _percentUnlock, _amount, uint256(0), uint256(0));
        userLockList[_to].push(lockstructure);
        return true;
    }
    function getUnlockedTokens() public view returns (uint256 _unlockedValue) {
      lockStructure[] storage lockstructure = userLockList[msg.sender];
      uint256 unlockedSum = 0;
      for (uint256 i = userUnlocks[msg.sender]; i < lockstructure.length; i++) {
        if (lockstructure[i].startLockTimestamp.add(lockstructure[i].unlockInterval.mul(lockstructure[i].countUnlocks.add(1))) < block.timestamp) {
          uint256 countUnlocks = block.timestamp.sub(lockstructure[i].startLockTimestamp).div(lockstructure[i].unlockInterval).sub(lockstructure[i].countUnlocks);
          if(countUnlocks >= lockstructure[i].unlocksNum.sub(lockstructure[i].countUnlocks)) {
              countUnlocks = lockstructure[i].unlocksNum.sub(lockstructure[i].countUnlocks);
          }
          if(countUnlocks > 0) {
          uint256 percentUnlocks = lockstructure[i].percentUnlock.mul(countUnlocks);
          uint256 balanceToUnlock = lockstructure[i].allLockedAmount.mul(percentUnlocks).div(10000);
          if(lockstructure[i].countUnlocks.add(countUnlocks) == lockstructure[i].unlocksNum) {
              balanceToUnlock = lockstructure[i].allLockedAmount.sub(lockstructure[i].UnLockedAmount);
          }
          if(balanceToUnlock > lockedBalanceOf[msg.sender]) { balanceToUnlock = lockedBalanceOf[msg.sender]; }
          unlockedSum += balanceToUnlock;
          }
        }
      }
      return unlockedSum;
    }

    function unlockTokens() external {
      lockStructure[] storage lockstructure = userLockList[msg.sender];
      uint256 unlockedSum = 0;
      for (uint256 i = userUnlocks[msg.sender]; i < lockstructure.length; i++) {
        if (lockstructure[i].startLockTimestamp.add(lockstructure[i].unlockInterval.mul(lockstructure[i].countUnlocks.add(1))) < block.timestamp && lockstructure[i].countUnlocks < lockstructure[i].unlocksNum) {
          uint256 countUnlocks = block.timestamp.sub(lockstructure[i].startLockTimestamp).div(lockstructure[i].unlockInterval).sub(lockstructure[i].countUnlocks);
          if(countUnlocks >= lockstructure[i].unlocksNum.sub(lockstructure[i].countUnlocks)) {
              countUnlocks = lockstructure[i].unlocksNum.sub(lockstructure[i].countUnlocks);
          }
          if(countUnlocks > 0) {
          uint256 percentUnlocks = lockstructure[i].percentUnlock.mul(countUnlocks);
          uint256 balanceToUnlock = lockstructure[i].allLockedAmount.mul(percentUnlocks).div(10000);
          if(lockstructure[i].countUnlocks.add(countUnlocks) == lockstructure[i].unlocksNum) {
              balanceToUnlock = lockstructure[i].allLockedAmount.sub(lockstructure[i].UnLockedAmount);
          }
          if(balanceToUnlock > lockedBalanceOf[msg.sender]) { balanceToUnlock = lockedBalanceOf[msg.sender]; }
          lockedBalanceOf[msg.sender] -= balanceToUnlock;
          lockstructure[i].UnLockedAmount += balanceToUnlock;
          lockstructure[i].countUnlocks += countUnlocks;
          unlockedSum += balanceToUnlock;
          if(lockstructure[i].allLockedAmount <= lockstructure[i].UnLockedAmount || lockstructure[i].countUnlocks >= lockstructure[i].unlocksNum) {
          userUnlocks[msg.sender]++;
          }
          emit Unlock(msg.sender, balanceToUnlock);
          }
        }
      }
    }
    function getUserLockers() external view returns(uint256 _locksCount) {
        return userLockList[msg.sender].length;
    }
    function getLockerDetails(address _owner, uint256 _index) external view returns(uint256 startLockTimestamp, uint256 unlockInterval, uint256 percentUnlock, uint256 allLockedAmount, uint256 UnLockedAmount, uint256 unlocksNum, uint256 countUnlocks) {
        if(msg.sender != owner()) {
            require(_owner == msg.sender, "You don't have permission to view this lockup");
        }
        lockStructure memory lockstructure = userLockList[_owner][_index];
        startLockTimestamp = lockstructure.startLockTimestamp;
        unlockInterval = lockstructure.unlockInterval;
        percentUnlock = lockstructure.percentUnlock;
        allLockedAmount = lockstructure.allLockedAmount;
        unlocksNum = lockstructure.unlocksNum;
        countUnlocks = lockstructure.countUnlocks;
        UnLockedAmount = lockstructure.UnLockedAmount;
    }

    function _checkDividends(address _from, address _to, uint256 _value) private {
       if(isDisabledDividends[_from] && isDisabledDividends[_to]) {
           return;
       }
       if(!isDisabledDividends[_from] && isDisabledDividends[_to]) {
           if(address(_processingRouter) != address(0) && address(_processingRouter) != _from && address(_processingRouter) != _to) _processingRouter.claim(_from);
           if(dividendTokens >= _value) dividendTokens -= _value;
           return;
       }
       if(isDisabledDividends[_from] && !isDisabledDividends[_to]) {
           if(address(_processingRouter) != address(0) && address(_processingRouter) != _from && address(_processingRouter) != _to) _processingRouter.claim(_to);
           if(dividendTokens.add(_value) <= totalSupply) dividendTokens += _value;
           return;
       }
       if(!isDisabledDividends[_from] && !isDisabledDividends[_to]) {
            if(address(_processingRouter) != address(0) && address(_processingRouter) != _from && address(_processingRouter) != _to) { 
            _processingRouter.claim(_from);
            _processingRouter.claim(_to); 
            }
           return;
       }
    }

    function _beforeTransfer(address _from, address _to, uint256 _value) internal returns (uint256 _newValue) {

        if (!isWhitelisted[_from] && !isWhitelisted[_to]) {
            require(isTradingEnabled, "Trading is disabled");
            require(!isBlacklisted[_from] && !isBlacklisted[_to], "Blacklisted address");
            require(balanceOf[_from].sub(lockedBalanceOf[_from]) > _value, "Not enought on balance, or some value in locked");
            require(_value <= maxTxAmount, "amount must be lower maxTxAmount");
            
            if (_from == pair) { 
                require(balanceOf[_to].add(_value) <= checkBuylimitLiquidity(), "amount must be lower than buy Limit Liquidity");
                lastTransfer[_to] = block.number;
            }
            if (_to == pair) {
                 require(lastTransfer[_from].add(blockTimeout) <= block.number, "not time yet");
            }
            if (antibot) {
                if (startBlock.add(deadBlocks) >= block.number) {
                    isBlacklisted[_to] = true;
                } else {
                    antibot = false;
                }
            }
            if(!isDisabledFee[_from]) {
                uint256 feeAmount = 0;
                if (_from == pair && marketingFee > 0) {
                feeAmount = _value.mul(marketingFee).div(10000);
                _toMarketing(_from, feeAmount);
                } else if (burnFee > 0) { 
                feeAmount = _value.mul(burnFee).div(10000);
                _burn(_from, feeAmount);
                }
                if(address(_processingRouter) != address(0)) {
                 if(lotteryFee > 0) { 
                    if (_to == pair) {
                    feeAmount += _value.mul(lotteryFee).div(10000); 
                     _toSwapAndProcessingLottery(_from, _value.mul(lotteryFee).div(10000));
                    } else { 
                    feeAmount += _value.mul(lotteryFee).div(10000);
                     _toProcessingLottery(_from, _value.mul(lotteryFee).div(10000));
                    }
                 }
                 if(holderFee > 0) { 
                  feeAmount += _value.mul(holderFee).div(10000);
                  if (_to == pair) {
                  _toSwapAndProcessingClaimable(_from, _value.mul(holderFee).div(10000));
                  } else { 
                  _toProcessingClaimable(_from, _value.mul(holderFee).div(10000));
                  }
                 }
                }
                uint256 newAmount = _value - feeAmount;
                _checkDividends(_from, _to, newAmount);
                return newAmount;
            } else {
                _checkDividends(_from, _to, _value);
                return _value;
            }
        }
        _checkDividends(_from, _to, _value);
        return _value;
    }

    function _transfer(address _from, address _to, uint256 _value) internal returns (bool success) {
        uint256 _newValue = _beforeTransfer(_from, _to, _value);
        if (_from == pair && lockIsEnabled) { 
                storeLocker(_to, lockReleaseTime, lockReleasePercent, _newValue); // lock with unlock 10%
                lockedBalanceOf[_to] += _newValue;
        }
        balanceOf[_from] -= _newValue;
        balanceOf[_to] += _newValue;
        
        if(balanceOf[_to] - _newValue == 0 && HolderID[_to] == 0 && _to != owner()) { HolderList[holders] = _to; HolderID[_to] = holders; holders++; }
       // if(balanceOf[_from] == 0) holders--;
        emit Transfer(_from, _to, _newValue);

        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }
    function getDividendTokens() public view returns (uint256 _DividendTokens) {
        return dividendTokens;
    }
    function getHolders() public view returns (uint256 _Holders) {
        return holders;
    }
    function getHolder(uint256 _index) public view returns (address _HolderAddress) {
        return HolderList[_index];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        _transfer(_from, _to, _value);
        allowance[_from][msg.sender] -= _value;
        return true;
    }

    function setDeadBlocks(uint256 _deadBlocks) public onlyOwner {
        deadBlocks = _deadBlocks;
    }

    function setisBlacklisted(address account, bool value) public onlyOwner {
        isBlacklisted[account] = value;
    }

    function setisDisabledFee(address account, bool value) public onlyOwner {
        isDisabledFee[account] = value;
    }

    function _setisDisabledDividends(address account, bool value) private {
     if(isDisabledDividends[account] != value) {
        if(balanceOf[account] > 0 && value) { 
          dividendTokens -= balanceOf[account];
        } else if(balanceOf[account] > 0 && !value) {
          dividendTokens += balanceOf[account];
        }
     }
        isDisabledDividends[account] = value;
    }
    function setisDisabledDividends(address account, bool value) public onlyOwner {
        return _setisDisabledDividends(account, value);
    }

    function multisetisBlacklisted(address[] calldata accounts, bool value) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            isBlacklisted[accounts[i]] = value;
        }
    }

    function setisWhitelisted(address account, bool value) public onlyOwner {
        isWhitelisted[account] = value;
    }

    function setBurnFee(uint256 value) public onlyOwner {
        require(value <= 5, "must be lower 5");
        marketingFee = value*100;
    }

    function setMarketingFee(uint256 value) public onlyOwner {
        require(value <= 5, "must be lower 5");
        marketingFee = value*100;
    }

    function setLotteryFee(uint256 value) public onlyOwner {
        require(value <= 5, "must be lower 5");
        lotteryFee = value*100;
    }

    function setHolderFee(uint256 value) public onlyOwner {
        require(value <= 10, "must be lower 10");
        holderFee = value*100;
    }

    function setbuyLimitLiquidity(uint256 value) public onlyOwner {
        require(value >= 0);
        buyLimitLiquidity = value;
    }

    function setAntibot(bool value) public onlyOwner {
        antibot = value;
    }

    function setLocksWhenBuy(bool value) public onlyOwner {
        lockIsEnabled = value;
    }

    function setLotteryIsEnabled(bool value) public onlyOwner {
        lotteryIsEnabled = value;
    }

    function openTrade(uint256 _amountTokens) external onlyOwner {
        require(!isTradingEnabled, "Trading is already enabled!");
        allowance[address(this)][address(_pancakeRouterV2)] = totalSupply;
        uint256 _busdAmount = _busd.balanceOf(address(this));
        require(_busdAmount > 0, "Zero Amount of pair token on contract");
        _busd.approve(address(_pancakeRouterV2), ~uint256(0));
        uint256 _tokenAmount = _amountTokens.mul(1e18);
        pair = PancakeSwapFactoryV2(_pancakeRouterV2.factory()).createPair(address(this), address(_busd));
        _pancakeRouterV2.addLiquidity(address(this),address(_busd),_tokenAmount,_busdAmount,_tokenAmount,_busdAmount,owner(),block.timestamp);
        IERC20(pair).approve(address(_pancakeRouterV2), ~uint256(0));
        isTradingEnabled = true;
        _setisDisabledDividends(pair, true);
        startBlock = block.number;
    }

    function openTradeManual(address _pairSet) external onlyOwner {
        require(!isTradingEnabled, "Trading is already enabled!");
        require(_busd.balanceOf(_pairSet) > 0 && balanceOf[_pairSet] > 0, "Pair of tokens has Zero liquidity");
        allowance[address(this)][address(_pancakeRouterV2)] = totalSupply;
        _busd.approve(address(_pancakeRouterV2), ~uint256(0));
        pair = _pairSet;
        IERC20(pair).approve(address(_pancakeRouterV2), ~uint256(0));
        isTradingEnabled = true;
        _setisDisabledDividends(pair, true);
        startBlock = block.number;
    }

    function setRouter(address newRouter) public onlyOwner returns (bool success) {
        _pancakeRouterV2 = PancakeSwapRouterV2(newRouter);
        return true;
    }

    function setBUSD(address newBusd) public onlyOwner returns (bool success) {
        _busd = IERC20(newBusd);
        return true;
    }

    function setMaxTxAmount(uint256 amount) public onlyOwner returns (bool success) {
        require(amount <= totalSupply, "cant be more than totalSupply");
        require(amount > 0, "cant be zero!");
        maxTxAmount = amount;
        return true;
    }

    function setBlockTimeout(uint256 newBlockTimeout) public onlyOwner returns (bool success) {
        require(newBlockTimeout <= 28800, "cant be more when 1 day!");
        blockTimeout = newBlockTimeout;
        return true;
    }

    function setDead(address newDead) public onlyOwner returns (bool success) {
        _dead = newDead;
        return true;
    }
    function setMarketing(address newMarketing) public onlyOwner returns (bool success) {
        _marketing = newMarketing;
        return true;
    }
    function setLockReleaseTime(uint256 _newLockReleaseTime) public onlyOwner returns (bool success) {
        require(_newLockReleaseTime <= 2592000, "cant be more when 30 days!");
        lockReleaseTime = _newLockReleaseTime;
        return true;
    }
    function setLockReleasePercent(uint256 _newLockReleasePercent) public onlyOwner returns (bool success) {
        require(_newLockReleasePercent <= 100 && _newLockReleasePercent > 1, "Lock must be from 1 to 100");
        lockReleasePercent = _newLockReleasePercent*100;
        return true;
    }
    
    function setProcessingRouter(address newProcessing) public onlyOwner returns (bool success) {
       if(address(_processingRouter) != address(0)) {  
        isWhitelisted[address(_processingRouter)] = false;
        _setisDisabledDividends(address(_processingRouter), false);
       }
       if(newProcessing != address(0)) {  
       isWhitelisted[newProcessing] = true;
        _setisDisabledDividends(newProcessing, true);
       }
        _processingRouter = ProcessingRouter(newProcessing);
        
        return true;
    }

    function setPair(address newPair) public onlyOwner returns (bool success) {
        _setisDisabledDividends(pair, false);
        _setisDisabledDividends(newPair, true);
        pair = newPair;
        return true;
    }
}