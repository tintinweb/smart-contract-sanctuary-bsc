// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./DividendPayingTokenETH.sol";
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";

contract DividendTracker is DividendPayingToken, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;    // 参与分红的地址
    uint256 public lastProcessedIndex; // 上次分红索引

    mapping (address => bool) public excludedFromDividends; // 不能领取分红的地址

    mapping (address => uint256) public lastClaimTimes; // 每个地址的上次领取时间
    uint256 public claimWait;  // 每个地址的最小间隔领取时间
    uint256 public minimumTokenBalanceForDividends; // 最低持币数量
    uint256 public processNum;

    event ExcludeFromDividends(address indexed account);
    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor() public DividendPayingToken("Dividend_Tracker", "Dividend_Tracker") {
    	claimWait = 3600;
        minimumTokenBalanceForDividends = 10000 * (10**18); //must hold 10000+ tokens
        processNum = 5;
    }

    function _transfer(address, address, uint256) internal override {
        require(false, "Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public override {
        require(false, "Dividend_Tracker: withdrawDividend disabled");
    }

    function excludeFromDividends(address account) external onlyOwner {
    	require(!excludedFromDividends[account]);
    	excludedFromDividends[account] = true;

    	_setBalance(account, 0);
    	tokenHoldersMap.remove(account);
    	emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        claimWait = newClaimWait;
    }

    function updateMin(uint256 newMinimumTokenBalanceForDividends) external onlyOwner {
        minimumTokenBalanceForDividends = newMinimumTokenBalanceForDividends;
    }

    function updateProcessNum(uint256 newProcessNum) external onlyOwner {
        processNum = newProcessNum;
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
    	if(lastClaimTime > block.timestamp)  {
    		return false;
    	}
    	return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    // 设置地址的余额
    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
    	if(excludedFromDividends[account]) {
    		return;
    	}

    	if(newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
    		tokenHoldersMap.set(account, newBalance);
    	}else {
            _setBalance(account, 0);
    		tokenHoldersMap.remove(account);
    	}

        // 如果该地址有分红, 则立即发放
    	processAccount(account, true);
    }

    // 处理固定数量的分红发放
    function processFixedNum() public {
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;
        if(numberOfTokenHolders == 0) {
            return;
        }
        uint256 _lastProcessedIndex = lastProcessedIndex;
        uint256 _processNum = processNum;

        for(uint256 i = 0; i < _processNum; i++) {
            _lastProcessedIndex++;
            if(_lastProcessedIndex >= tokenHoldersMap.keys.length) {
                _lastProcessedIndex = 0;
            }
            address account = tokenHoldersMap.keys[_lastProcessedIndex];
            if(canAutoClaim(lastClaimTimes[account])) {
                processAccount(payable(account), true);
            }
        }

        lastProcessedIndex = _lastProcessedIndex;
    }

    // 根据gas来处理, 返回迭代次数, 实际处理次数, 最终处理完的索引
    function process(uint256 gas) public returns (uint256, uint256, uint256) {
    	uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;
    	if(numberOfTokenHolders == 0) {
    		return (0, 0, lastProcessedIndex);
    	}
    	uint256 _lastProcessedIndex = lastProcessedIndex;
    	uint256 gasUsed = 0;
    	uint256 gasLeft = gasleft();   // remaining gas
    	uint256 iterations = 0;
    	uint256 claims = 0;

    	while(gasUsed < gas && iterations < numberOfTokenHolders) {    // gasUsed 大于 定量的gas 则结束
    		_lastProcessedIndex++;
    		if(_lastProcessedIndex >= tokenHoldersMap.keys.length) {
    			_lastProcessedIndex = 0;
    		}
    		address account = tokenHoldersMap.keys[_lastProcessedIndex];
    		if(canAutoClaim(lastClaimTimes[account])) {
    			if(processAccount(payable(account), true)) {
    				claims++;
    			}
    		}
    		iterations++;
    		uint256 newGasLeft = gasleft();
    		if(gasLeft > newGasLeft) {
    			gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));  // gasUsed 每次累加
    		}
    		gasLeft = newGasLeft;
    	}

    	lastProcessedIndex = _lastProcessedIndex;
    	return (iterations, claims, lastProcessedIndex);
    }

    // 给account提取分红, 并更新领取时间
    function processAccount(address payable account, bool automatic) public onlyOwner returns (bool) {
        // account提取分红
        uint256 amount = _withdrawDividendOfUser(account);
    	if(amount > 0) {
    		lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
    		return true;
    	}
    	return false;
    }

    // 总的可领取分红的地址数
    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }

    // 通过id查找
    function getAccountAtIndex(uint256 index) public view returns (address,int256,int256,uint256,uint256,uint256,uint256,uint256){
        if(index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);
        }
        address account = tokenHoldersMap.getKeyAtIndex(index);
        return getAccount(account);
    }

    // 地址, 地址索引, 需要多少次才能到此地址, 该地址可提分红, 总分红, 上次领取分红的时间, 下次可领取分红的时间, 倒计时
    function getAccount(address _account) public view returns (address account, int256 index, int256 iterationsUntilProcessed, uint256 withdrawableDividends, uint256 totalDividends, 
        uint256 lastClaimTime, uint256 nextClaimTime, uint256 secondsUntilAutoClaimAvailable) {
        account = _account;
        index = tokenHoldersMap.getIndexOfKey(account); // 该地址对应索引, 如果不存在, 则默认-1
        iterationsUntilProcessed = -1;  // 迭代多少次才能到该地址, 该地址不存在, 则默认-1
        if(index >= 0) {
            // 如果该地址索引大于上次发放奖励的索引
            if(uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            } else { // 正常情况下, tokenHoldersMap.keys.length > lastProcessedIndex
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ? tokenHoldersMap.keys.length.sub(lastProcessedIndex) : 0;
                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }

        withdrawableDividends = withdrawableDividendOf(account); // 该地址可提分红
        totalDividends = accumulativeDividendOf(account);   // 该地址总的分红 = 可提 + 已提
        lastClaimTime = lastClaimTimes[account]; // 上次领取分红的时间
        nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(claimWait) : 0; // 下次可领取分红的时间
        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ? nextClaimTime.sub(block.timestamp) : 0; // 倒计时
    }
}