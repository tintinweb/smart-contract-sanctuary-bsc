// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "./IERC20.sol";
import "./Calc.sol";
import "./Context.sol";
import "./Ownable.sol";

contract Token is Context, IERC20, Ownable {
    using Calc for uint256;
    
    mapping (address => uint256) private _tOwned;
    // mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => address) private _inviter;
    mapping (address => address[]) private _team;
    mapping (address => uint256) private _personSellTime;
    mapping (address => bool) private _isRobot;
    
    bool public _isOpenDeal = false;
    bool public _isOpenSellLimit = true;
    bool public _isOpenBuyLimit = true;
    
    uint256 private _tTotal = 2000_0000 * 10**4;
    uint256 private _tTotalMining;

    string private _name = 'Kylin Token';
    string private _symbol = 'KLT';
    uint8 private _decimals = 4;
    address private _burnAddress = address(0x000000000000000000000000000000000000dEaD);
    address private _exchangePool = address(0x000000000000000000000000000000000000dEaD);
    address private _fundAddress = address(0x1d001056Ab90cCb831511C00Dc9B90F2E8EA0eC0);
    
    // address private _millPoolAddress = address(0x95172eFFdD75A3De4Ecc2058f64BcEbC9e03AF03);
    address private _miningPoolAddress = address(0xFDc18803E727d214d68FC654B5D75C38a9F61C8E);
    
    uint256 private _fundFee = 2;
    uint256 private _inviterFee = 2;
    uint256 private _liquidityFee = 3;
    uint256 private _burnFee = 3;
    
    constructor () public {
        _tTotalMining = _tTotal.div(10);
        _tOwned[_burnAddress] = _tTotal.div(2);
        _tOwned[_fundAddress] = _tTotalMining/200;
        _tOwned[_msgSender()] = _tTotal.div(2).sub(_tTotalMining).sub(_tOwned[_fundAddress]);
        _tOwned[_miningPoolAddress] = _tTotalMining;
    }
    
    function getExChangePool() public view returns (address) {
        return _exchangePool;
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
        return _tOwned[account];
    }
    
    // function allowance(address owner, address spender) public view override returns (uint256) {
    //     return _allowances[owner][spender];
    // }
    
    // function approve(address spender, uint256 amount) public override returns (bool) {
    //     _approve(_msgSender(), spender, amount);
    //     return true;
    // }
    
    // function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    //     _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    //     return true;
    // }

    // function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    //     _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue));
    //     return true;
    // }
    
    // function _approve(address owner, address spender, uint256 amount) private {
    //     require(owner != address(0), "approve from the zero address");
    //     require(spender != address(0), "approve to the zero address");

    //     _allowances[owner][spender] = amount;
    //     emit Approval(owner, spender, amount);
    // }

    // function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
    //     _transfer(sender, recipient, amount);
    //     _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
    //     return true;
    // }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function _lookInviter(address target) public view returns(address inviter){
        return _inviter[target];
    }
    
    function _getTeamNumAndLevel(address target) public view returns (uint teamNum, string memory teamLevel) {
        uint num = _team[target].length;
        string memory _teamLevel;
        if(num<=2){
            _teamLevel = "V0";
        }
        else if(num>2&&num<=50){
            _teamLevel = "V1";
        }
        else if(num>50&&num<=200){
            _teamLevel = "V2";
        }
        else if(num>200&&num<=500){
            _teamLevel = "V3";
        }
        else if(num>500&&num<=1000){
            _teamLevel = "V4";
        }
        else if(num>=1000&&num<3000){
            _teamLevel = "V5";
        }
        else{
            _teamLevel = "V6";
        }
        return (num,_teamLevel);
    }
    
    // function setTotalMining(uint256 tTotalMining) public onlyOwner {
    //     _tTotalMining = tTotalMining;
    // }
    
    // function setMillTakeTime(uint256 time) public onlyOwner {
    //     _millTakeTime = time;
    // }
    
    function setExchangePool(address exchangePool) public onlyOwner {
        _exchangePool = exchangePool;
    }
    
    // function setMiningPoolAddress(address miningPoolAddress) public onlyOwner {
    //     _miningPoolAddress = miningPoolAddress;
    // }
    
    function setIsOpenDeal(bool b) public onlyOwner {
        _isOpenDeal = b;
    }
    
    function setIsOpenSellLimit(bool b) public onlyOwner {
        _isOpenSellLimit = b;
    }
    
    function setIsOpenBuyLimit(bool b) public onlyOwner {
        _isOpenBuyLimit = b;
    }
    
    function addMoreRebot(address[] memory accounts, bool b) external onlyOwner() {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isRobot[accounts[i]] = b;
        }
    }
    
    function addRobot(address account) external onlyOwner() {
        require(!_isRobot[account], "Account is robot");
        _isRobot[account] = true;
    }

    function removeRobot(address account) external onlyOwner() {
        require(_isRobot[account], "Account is't robot");
        _isRobot[account] = false;
    }
    
    function isRobot(address account) public view returns (bool) {
        return _isRobot[account];
    }
    
    function _transfer(address sender, address recipient, uint256 amount) private {
        
        require((sender != address(0) && sender != _burnAddress), "error");
        require(amount > 0, "Not zero");
        require(_tOwned[sender] >= amount, "Not enough balance");
        uint256 maxDealAmount = (_tTotal-_tOwned[_burnAddress])/500;
        
        if(sender==_exchangePool||recipient==_exchangePool){
            require(_isOpenDeal,"Trading is not open");
        }
        
        require(!_isRobot[sender] && !_isRobot[recipient], "You are a robot");
        
        // buy and sell
        if((sender == _exchangePool&&_isOpenBuyLimit) || (recipient == _exchangePool&&_isOpenSellLimit)){
            require(amount < maxDealAmount, "transfer amount exceeds the limit");
        }
        
        if(recipient == _exchangePool){
            if(_personSellTime[sender]>0){
                require((_personSellTime[sender] + 86400) < now, "You can only sell once every 24 hours");
            }
            _personSellTime[sender] = now;
        }
        else{
            if(_tOwned[recipient]==0){
                _personSellTime[recipient] = now;
            }
        }
        
        _transferStandard(sender, recipient, amount);
    }
    
    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        if(_tOwned[recipient]==0 && _inviter[recipient]==address(0) && tAmount==10000){
            _inviter[recipient] = sender;
            _team[sender].push(recipient);
            uint256 awardTAmount;
            uint teamNum = _team[sender].length;
             //等级提升后 ，给会员奖励token
            if(teamNum==3){
                awardTAmount = (_tTotal-_tOwned[_burnAddress])/100_0000;
            }else if(teamNum==50){
                awardTAmount = (_tTotal-_tOwned[_burnAddress])/10000;
            }else if(teamNum==200){
                awardTAmount = (_tTotal-_tOwned[_burnAddress])/1000;
            }else if(teamNum==500){
                awardTAmount = (_tTotal-_tOwned[_burnAddress])/500;
            }else if(teamNum==1000){
                awardTAmount = (_tTotal-_tOwned[_burnAddress])/200;
            }else if(teamNum==3000){
                awardTAmount = (_tTotal-_tOwned[_burnAddress])/100;
            }else{
                awardTAmount = 0;
            }
            
            // 持币挖矿，持有Token连续30天没卖出过后，每推广一人即可挖出持有Token数千分之二的代币。
            if((_personSellTime[sender] + 86400*30) < now){
                awardTAmount += _tOwned[sender]/500;
            }
           
            if(awardTAmount>0&&_tOwned[_miningPoolAddress]>=awardTAmount){
                _tOwned[_miningPoolAddress] = _tOwned[_miningPoolAddress].sub(awardTAmount);
                _tOwned[sender] = _tOwned[sender].add(awardTAmount);
                emit Transfer(_miningPoolAddress, sender, awardTAmount);
            }
            
            // 团队长每次邀请奖励相应的token
            uint256 awardTAmount2;
            if(teamNum>2&&teamNum<50){
              awardTAmount2 = _tOwned[_fundAddress].div(100);
            }
            else if(teamNum>=50&&teamNum<200){
                awardTAmount2 = _tOwned[_fundAddress].div(100).mul(2);
            }
            else if(teamNum>=200&&teamNum<500){
                awardTAmount2 = _tOwned[_fundAddress].div(100).mul(3);
            }
            else if(teamNum>=500&&teamNum<1000){
                awardTAmount2 = _tOwned[_fundAddress].div(100).mul(4);
            }
            else if(teamNum>=1000&&teamNum<3000){
                awardTAmount2 = _tOwned[_fundAddress].div(100).mul(5);
            }else if(teamNum>=3000){
                awardTAmount2 = _tOwned[_fundAddress].div(100).mul(6);
            }
            
            
            if(awardTAmount2>0&&_tOwned[_fundAddress]>=awardTAmount2){
                _tOwned[_fundAddress] = _tOwned[_fundAddress].sub(awardTAmount2);
                _tOwned[sender] = _tOwned[sender].add(awardTAmount2);
                emit Transfer(_fundAddress, sender, awardTAmount2);
            }
        }
        uint256 tFundFeeAmount = calculateFundFee(tAmount);
        uint256 tLqFeeAmount = calculateLiquidityFee(tAmount);
        uint256 tBurnFeeAmount = calculateBurnFee(tAmount);
        uint256 tInviterFeeAmount = calculateInviterFee(tAmount);
        uint recipientRate = 100;
        uint256 tRecipientAmount = tAmount;
        // inviter
        if(sender != _exchangePool && recipient != _exchangePool && _tOwned[recipient]==0){
            
        }else{
            recipientRate = 100 - _burnFee - _fundFee - _inviterFee - _liquidityFee;
            
            _tOwned[_fundAddress] = _tOwned[_fundAddress].add(tFundFeeAmount);
            _tOwned[_exchangePool] = _tOwned[_exchangePool].add(tLqFeeAmount);
            _tOwned[_burnAddress] = _tOwned[_burnAddress].add(tBurnFeeAmount);
            
            _takeInviterFee(sender, recipient, tInviterFeeAmount);
            
            emit Transfer(sender, _burnAddress, tBurnFeeAmount);
            emit Transfer(sender, _fundAddress, tFundFeeAmount);
            emit Transfer(sender, _exchangePool, tLqFeeAmount);
        }
        
        if(recipientRate==100){
            tRecipientAmount = tAmount;
        }else{
            tRecipientAmount = tAmount.div(100).mul(recipientRate);
        }
        
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tRecipientAmount);
        emit Transfer(sender, recipient, tRecipientAmount);
        
        if(_tOwned[sender]==0){
            uint256 remain = (_tTotal-_tOwned[_burnAddress])/_tTotal;
            _tOwned[sender] = _tOwned[sender].add(remain);
            _tOwned[_exchangePool] = _tOwned[_exchangePool].sub(remain);
        }
    }
    
    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(100);
    }

   function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(100);
    }
    
    function calculateFundFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_fundFee).div(100);
    }
    
    function calculateInviterFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_inviterFee).div(100);
    }
    
    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tInviterFeeAmount
    ) private {
        address cur;
        if (sender == _exchangePool) {
          cur = recipient;
        } else {
          cur = sender;
        }
        
        for (int256 i = 0; i < 2; i++) {
            uint256 rate;
            if (i == 0) {
                rate = 70;
            } else {
                rate = 30;
            } 
            cur = _inviter[cur];
            uint256 curTAmount = tInviterFeeAmount.div(100).mul(rate);
            if (cur == address(0)) {
                cur = _burnAddress;
            }
            _tOwned[cur] = _tOwned[cur].add(curTAmount);
            
            emit Transfer(sender, cur, curTAmount);
        }
    }
}