// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./DateTime.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract MUTTokenBase is Context, IERC20, IERC20Metadata, Ownable {

    address airdropper;
    bool bVest = false;
    uint beginVestTime;
    uint createdTime;
    uint8 constant VEST_CLIPS = 12;

    mapping(address => uint256) private _normalBalances;
    mapping(address => uint256) private _vestAmounts;
    mapping(address => uint256) private _vestBalances;
    mapping(address => mapping(uint16 => bool)) _vestHistory;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    mapping(address => bool) private _blackListSpender;
    uint32 blackListCount;
    mapping(uint32 => address) mapBlackList;

    mapping(address => bool) private _airdropConsumers;
    uint32 airdropConsumerCount;
    mapping(uint32 => address) mapAirdropConsumer;

    event vested(address to, uint256 amount);

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        owner = _msgSender();
        createdTime = block.timestamp;
    }

    function approveAirdropper(address to) external onlyOwner {
        require(to != airdropper, "Target account have been airdropper");
        airdropper = to;
    }

    function airdropperOfToken() external view returns (address) {
        return airdropper;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _normalBalances[account] + _vestBalances[account];
    }

    function withdrawableAmount(address account) public view returns (uint256) {
        return _normalBalances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        require(!_blackListSpender[spender], "Spender have been banned");
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        require(!_blackListSpender[spender], "Spender have been banned");

        _spendAllowance(from, spender, amount);
        _transfer(spender, from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        require(!_blackListSpender[spender], "Spender have been banned");

        (bool result, uint256 approveAmount) = SafeMath.tryAdd(allowance(owner, spender), addedValue);
        if(!result) {
            return false;
        }
        _approve(owner, spender, approveAmount);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        require(!_blackListSpender[spender], "Spender have been banned");

        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            (bool result, uint256 approveAmount) = SafeMath.trySub(currentAllowance, subtractedValue);
            if(!result) {
                return false;
            }
            _approve(owner, spender, approveAmount);
        }

        return true;
    }

    function setVestStatus(bool status) external onlyOwner {
        require(bVest != status, "set the same status error");
        bVest = status;
    }

    function setVestTime(uint timestamp) external onlyOwner {
        require(timestamp >= createdTime, "Vest time set error, can not be less then the contract created time");
        beginVestTime = timestamp;
    }

    function vest() external onlyOwner {
        require(_msgSender() != address(0), "ERC20: transfer from the zero address");
        require(_msgSender() != airdropper, "Airdropper should not vest token");

        uint nowTimestamp = block.timestamp;

        require(bVest, "Token not vested yet");
        require(nowTimestamp > beginVestTime, "Vest time set error");

        require(_vestBalances[_msgSender()] > 0, "Have no token balance to vest");

        uint16 beginYear = beginVestTime > 0 ? DateTime.getYear(beginVestTime) : 0;
        uint8 beginMonth = beginVestTime > 0 ? DateTime.getMonth(beginVestTime) : 0;
        uint16 nowYear = DateTime.getYear(nowTimestamp);
        uint8 nowMonth = DateTime.getMonth(nowTimestamp);

        (bool mRes, uint16 diffMonth) = DateTime.monthDiff(beginYear, beginMonth, nowYear, nowMonth);
        require(mRes, "Token not vested yet due to date");

        require(!_vestHistory[_msgSender()][diffMonth], "You have vested amounts this month");

        (bool ok, uint256 vestAmount) = _vest(_msgSender(), diffMonth);

        if(!ok) {
            revert("vest error");
        }

        for(uint8 i = 0; i <= diffMonth; i ++){
            if(!_vestHistory[_msgSender()][i]){
                _vestHistory[_msgSender()][i] = true;
            }
        }

        emit vested(_msgSender(), vestAmount);
    }

    function vestableAmount(address account) external view returns (uint256) {
        return _vestBalances[account];
    } 

    function getVestNode(address account, uint8 monthIndex) external view returns (bool status, uint256 amount, uint256 percent, uint timestamp) {
        if(monthIndex > 4) {
            return (false, 0, 0, 0);
        } else {
            status = _vestHistory[account][monthIndex];
            amount = _getVestAmountOfMonth(account, monthIndex);
            percent = 1000 * amount / _vestAmounts[account];

            uint8 beginMonth = DateTime.getMonth(beginVestTime);
            uint16 beginYear = DateTime.getYear(beginVestTime);
            uint8 nextMonth = beginMonth;
            uint16 nextYear = beginYear;
            for(uint8 i = 0; i < monthIndex; i ++) {
                (nextMonth, nextYear) = DateTime.nextYearMonth(nextMonth, nextYear);
            }

            timestamp = DateTime.toTimestamp(nextYear, nextMonth, 1);  
        }  
    }

    function _vestPercent(uint16 monthIndex) internal pure returns (uint256 percent) {
        if(monthIndex == 0) {
            return 5;
        } else if (monthIndex == 1) {
            return 10;
        } else if (monthIndex == 2) {
            return 15;
        } else if (monthIndex == 3) {
            return 26;
        } else if (monthIndex == 4) {
            return 44;
        } else {
            return 100;
        }
    }

    function vestStatus() external view returns (bool status, uint beginTime) {
        status = bVest;
        beginTime = beginVestTime;
    }

    function _vest(address account, uint16 monthIndex) internal returns(bool res, uint256 vestAmount){

        uint256 releaseAmount = 0;

        for(uint16 i = 0; i <= monthIndex && i <= 4; i ++ ){
            if(!_vestHistory[account][i]) {
                releaseAmount += _getVestAmountOfMonth(account, i);
            }
        }
        
        if(releaseAmount > _vestBalances[account]) {
            releaseAmount = _vestBalances[account];
        }
        (bool resultV, uint256 vLeftBalance) = SafeMath.trySub(_vestBalances[account], releaseAmount);
        if(resultV) {
            _vestBalances[account] = vLeftBalance;
            (bool resultN, uint256 nLeftBalance) = SafeMath.tryAdd(_normalBalances[account], releaseAmount);
            if(resultN) {
                _normalBalances[account] = nLeftBalance;
                res = true;
                vestAmount = releaseAmount;
            }
        }
    }

    function _getVestAmountOfMonth(address account, uint16 monthIndex) internal view returns (uint256 vestAmount) {
        uint256 percent = _vestPercent(monthIndex);
        vestAmount = _vestAmounts[account] * percent / 100;
        uint256 sumBeforeMonth = _sumVestAmountBeforeMonth(account, monthIndex);
        if(vestAmount > (_vestBalances[account] - sumBeforeMonth)) {
            vestAmount = _vestBalances[account] - sumBeforeMonth;
        }
    }

    function _sumVestAmountBeforeMonth(address account, uint16 monthIndex) internal view returns(uint256 sumAmount) {
        for(uint16 i = 0; i < monthIndex; ++i) {
            sumAmount += _getVestAmountOfMonth(account, i);
        }
    }

    function _transfer(
        address spender,
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint nowTimestamp = block.timestamp;
        uint16 beginYear = beginVestTime > 0 ? DateTime.getYear(beginVestTime) : 0;
        uint8 beginMonth = beginVestTime > 0 ? DateTime.getMonth(beginVestTime) : 0;
        uint16 nowYear = DateTime.getYear(nowTimestamp);
        uint8 nowMonth = DateTime.getMonth(nowTimestamp);
        
        (bool mRes, uint16 diffMonth) = DateTime.monthDiff(beginYear, beginMonth, nowYear, nowMonth);
        
        if(!bVest && !mRes && diffMonth >= 0 && airdropper == from) {
            _transferToVest(from, to, amount);
        } else {
            _transferToNormal(spender, from, to, amount);
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _transferToVest(
        address from, 
        address to,
        uint256 amount
    ) internal {
        require(from == airdropper, "Only owner can transfer token to vest account");
        uint256 airdropperBalance = _normalBalances[airdropper];
        require(airdropperBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            (bool resultFrom, uint256 leftBalance) = SafeMath.trySub(airdropperBalance, amount);
            if(resultFrom) {
                _normalBalances[airdropper] = leftBalance;
            }
        }

        (bool resultTo, uint256 toBalance) = SafeMath.tryAdd(_vestBalances[to], amount);
        (bool resultTo_2, uint256 toAmount) = SafeMath.tryAdd(_vestAmounts[to], amount);
        if(resultTo && resultTo_2) {
            _vestAmounts[to] = toAmount;
            _vestBalances[to] = toBalance;
        }
    }

    function _transferToNormal(
        address spender,
        address from,
        address to,
        uint256 amount
    ) internal {

        if(_normalBalances[from] >= amount) {
            _normalBalances[from] -= amount;
        }else{
            if(_airdropConsumers[spender]) {
                require(_vestBalances[from] >= amount - _normalBalances[from], "insufficient balance 3");
                _normalBalances[from] = 0;
                _vestBalances[from] -= amount - _normalBalances[from];
            }else{
                revert("insufficient balance 4");
            }
        }

        _normalBalances[to] += amount;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        (bool resultS, uint256 resultSupply) = SafeMath.tryAdd(_totalSupply, amount);
        if(resultS) {
            _totalSupply = resultSupply;
        }
        
        (bool resultB, uint256 resultBalance) = SafeMath.tryAdd(_normalBalances[account], amount);
        if(resultB) {
            _normalBalances[account] = resultBalance;
        }
        
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        //Priority use of normal amount
        if(_normalBalances[owner] >= amount) {
            _allowances[owner][spender] = amount;
        }else{
            //use airdrop amount if there is not enough in normal account
            if(_airdropConsumers[spender]) {
                require(_normalBalances[owner] + _vestBalances[owner] >= amount, "insufficient balance 1");
                _allowances[owner][spender] = amount;
            }else{
                revert("insufficient balance 2");
            }
        }
        
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                (bool result, uint256 approveAmount) = SafeMath.trySub(currentAllowance, amount);
                if(result) {
                    _approve(owner, spender, approveAmount);
                }
            }
        }
    }

    function addBlackListSpender(address spender) external onlyOwner {
        _blackListSpender[spender] = true;
        mapBlackList[++blackListCount] = spender;
    }

    function isSpenderInBlackList(address spender) external view returns (bool res) {
        res = _blackListSpender[spender];
    }

    function getBlackListCount() external view returns (uint32 res) {
        res = blackListCount;
    }

    function getBlackListAddress(uint32 index) external view returns (address res) {
        res = mapBlackList[index];
    }

    function removeBlackListSpender(address spender) external onlyOwner {
        delete _blackListSpender[spender];
    }

    function addAirdropConsumer(address consumer) external onlyOwner {
        _airdropConsumers[consumer] = true;
        mapAirdropConsumer[++airdropConsumerCount] = consumer;
    }

    function isAirdropConsumer(address consumer) external view returns (bool res) {
        res = _airdropConsumers[consumer];
    }

    function getAirdropConsumerCount() external view returns (uint32 res) {
        res = airdropConsumerCount;
    }

    function getAirdropConsumerAddress(uint32 index) external view returns (address res) {
        res = mapAirdropConsumer[index];
    }

    function removeAirdropConsumer(address consumer) external onlyOwner {
        delete _airdropConsumers[consumer];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}
}

/**
 * MUTToken contract
 */
contract MUTToken is MUTTokenBase {
    constructor() MUTTokenBase("Mutual Farm Token", "MUT") {
        _mint(msg.sender, 200000000 * 10 ** 18);
    }
}