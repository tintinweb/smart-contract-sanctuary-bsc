/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address public _owner;

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
   
    function renounceOwnership() public  onlyOwner {
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public  onlyOwner {
        require(newOwner != address(0),"Ownable: new owner is thezeroAddress address");
        _owner = newOwner;
    }
}

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
            // Gas optimization: this is cheaper than requiring 'a' not beingzeroAddress, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract LPTokenMiner is Ownable {
    using SafeMath for uint256;

    uint256 public _daySecond = 10;
    uint256 public date = 50;
    uint256 public minerCycle = 360;
    uint256 public releaseCycle = 360;
    uint256 public option1;
    uint256 public option2;
    uint256 public option3;
    uint256 public option4;
    uint256 public stage1;
    uint256 public stage2;
    uint256 public stage3;
    uint256 public stage4;
    uint256 public totalLpAmount;
    uint256 public coppvTotalAmount;
    uint256 private coppvTotalAmountCopy;
    uint256 public fee1Rate;
    uint256 public fee2Rate;
    uint256 private _decimals;

    address private _ccb;
    address private _coppv;
    address private _ccbPair;
    address public fundAddress = 0x2010Cef841a348b10cb31c69C69624DFaB266C4b; // 需要修改

    mapping (uint256 => Option) private _option;
    mapping (address => Relation) private _relation;
    mapping (address => DepositOption[]) private _depositOption;
    mapping (address => LinearRelease[]) private _balanceLinearRelease;

    struct Option {
        uint256 day;
        uint256 amount;
    }

    struct Relation {
        address one;
        address two;
    }

    struct DepositOption {
        uint256 option;
        uint256 startime;
        uint256 endtime;
        uint256 lastime;
        uint256 depositAmount;
        uint256 day;
        bool complete;
    }

    struct LinearRelease {
        uint256 point;
        uint256 balance;
        uint256 release;
        uint256 totalReward;
        uint256 lastime;
    }

    event Deposit(address indexed sender, uint256 amount);
    event WithdrawPoint(address indexed sender, uint256 amount);
    event WithdrawlLPToken(address indexed sender, uint256 amount);
    event WithdrawLinearRelease(address indexed sender, uint256 amount);
    
    constructor(address ccb_, address coppv_, address ccbPair_) {
        _owner = msg.sender;
        _ccb = ccb_;
        _coppv = coppv_;
        _ccbPair = ccbPair_;
        _decimals = 6;
        stage1 = 45;
        stage2 = 90;
        stage3 = 180;
        stage4 = 360;
        option1 = 120000*10**_decimals;
        option2 = 280000*10**_decimals;
        option3 = 600000*10**_decimals;
        option4 = 1000000*10**_decimals;
        coppvTotalAmount = 50000000*10**_decimals;
        coppvTotalAmountCopy = coppvTotalAmount;
        fee1Rate = 30;
        fee2Rate = 20;
        _option[stage1] = Option(stage1, option1);
        _option[stage2] = Option(stage2, option2);
        _option[stage3] = Option(stage3, option3);
        _option[stage4] = Option(stage4, option4);
    }

    function bindRelationShip(address _one, address _two) external {
        require(_one != msg.sender && _two != msg.sender);
        _relation[msg.sender] = Relation(_one, _two);
    }

    function getRelationExist(address account) public view returns(bool){
        return _relation[account].one == address(0) ? false : true;
    }

    function getDepositOption(address account) public view returns(DepositOption[] memory){
        return _depositOption[account];
    }

    // 获取上一次领取时间到当前产生的预计收益
    function getCurrentEstimateReward(address account) external view returns(uint256){
        if (totalLpAmount == 0){
            return 0;
        }
        uint256 preAmount;
        for (uint i = 0; i < _depositOption[account].length; i++){
            if (block.timestamp > _depositOption[account][i].endtime){
                continue;
            }
            uint256 option = _depositOption[account][i].option;
            if (_depositOption[account][i].day >= option) {// 领取次数超过option会失败
                continue;
            }
            uint256 rewardAmount = _option[option].amount;
            uint256 depositLpAmount = _depositOption[account][i].depositAmount;
            uint256 interval = block.timestamp - _depositOption[account][i].lastime;
            preAmount = preAmount.add(rewardAmount.mul(depositLpAmount).mul(interval).div(minerCycle*_daySecond).div(totalLpAmount));
        }
        return preAmount;
    }

    // 获取未释放余额 已释放余额
    function getReleaseBalance(address account) external view returns(uint256, uint256){

        uint256 noReleaseAmount;
        uint256 releaseAmount;
        for (uint i = 0; i < _balanceLinearRelease[account].length; i++){
            noReleaseAmount = noReleaseAmount.add(_balanceLinearRelease[account][i].balance);
            releaseAmount = releaseAmount.add(_balanceLinearRelease[account][i].release);
        }
        return(noReleaseAmount, releaseAmount);
    }

    function getCanWithdrawPoint(address account) external view returns(uint256){
        uint256 ccbAmount;
        for (uint i = 0; i < _depositOption[account].length; i++){
            if (block.timestamp <= _depositOption[account][i].lastime + _daySecond){
                continue;
            }
            uint256 option = _depositOption[account][i].option;
            if (_depositOption[account][i].day >= option) {
                continue;
            }
            uint256 rewardAmount = _option[option].amount;
            uint256 depositLpAmount = _depositOption[account][i].depositAmount;
            uint256 interval = (block.timestamp - _depositOption[account][i].lastime)/_daySecond;
            if (_depositOption[account][i].day + interval > option){
                interval = option - _depositOption[account][i].day;
            }
            ccbAmount = ccbAmount.add(rewardAmount.mul(depositLpAmount).mul(interval).div(minerCycle).div(totalLpAmount));
            if (ccbAmount <= 0){
                continue;
            }
        }
        return ccbAmount;
    }

    function getCanWithdrawRelease(address account) external view returns(uint256) {
        uint256 totalAmount;
        for (uint i = 0; i < _balanceLinearRelease[account].length; i++) {
            if (_balanceLinearRelease[account][i].balance <= 0) {
                continue;
            }
            if (block.timestamp < _balanceLinearRelease[account][i].lastime) {
                continue;
            }
            uint256 withdrawAmount = _balanceLinearRelease[account][i].totalReward.mul(block.timestamp - _balanceLinearRelease[account][i].lastime).div(releaseCycle*_daySecond);
            if (withdrawAmount <= 0) {
                continue;
            }
            if (_balanceLinearRelease[account][i].balance < withdrawAmount){
                withdrawAmount = _balanceLinearRelease[account][i].balance;
            }
            uint256 fee1 = withdrawAmount.mul(fee1Rate).div(1000);
            uint256 fee2 = withdrawAmount.mul(fee2Rate).div(1000);
            totalAmount = totalAmount.add(withdrawAmount - fee1 - fee2);
        }
        return totalAmount;
    }

    function getCanWithdrawLPToken(address account) external view returns(uint256){
        uint256 withdrawAmount;
        for (uint i = 0; i < _depositOption[account].length; i++){
            if (block.timestamp < _depositOption[account][i].endtime){
                continue;
            }
            uint256 depositAmount = _depositOption[account][i].depositAmount;
            if (_depositOption[account][i].complete){
                continue;
            }
            withdrawAmount = withdrawAmount.add(depositAmount);
        }
        return withdrawAmount;
    }

    function deposit(uint256 amount, uint256 option) external { //需要先授权
        require(amount > 0, "LP: Please enter the correct amount");
        require(_option[option].day != 0, "LP: Please enter the correct option");
        uint256 approveAmount = IERC20(_ccbPair).allowance(msg.sender, address(this));
        require(approveAmount >= amount, "LP: Insufficient authorized amount");
        IERC20(_ccbPair).transferFrom(msg.sender, address(this), amount);
        totalLpAmount =  totalLpAmount.add(amount);
        _depositOption[msg.sender].push(DepositOption(option, block.timestamp, block.timestamp+(option+1)*_daySecond, block.timestamp, amount, 0, false));
        _balanceLinearRelease[msg.sender].push(LinearRelease(0, 0, 0, 0, 0));
        emit Deposit(msg.sender, amount);
    }

    function withdrawlLPToken() external {
        address sender = msg.sender;
        uint256 withdrawAmount;
        for (uint i = 0; i < _depositOption[sender].length; i++){
            if (block.timestamp < _depositOption[sender][i].startime + _depositOption[sender][i].option*_daySecond){
                continue;
            }
            uint256 depositAmount = _depositOption[sender][i].depositAmount;
            if (_depositOption[sender][i].complete){
                continue;
            }
            _depositOption[sender][i].complete = true;
            totalLpAmount = totalLpAmount.sub(depositAmount);
            withdrawAmount = withdrawAmount.add(depositAmount);
        }
        require(withdrawAmount > 0, "LP: Pledge has no period and cannot be withdrawn");
        IERC20(_ccbPair).transfer(sender, withdrawAmount);
        emit WithdrawlLPToken(sender, withdrawAmount);
    }

    function withdrawPoint() external {
        address sender = msg.sender;
        uint256 coppvAmount;
        uint256 ccbAmount;
        for (uint i = 0; i < _depositOption[sender].length; i++){
            if (block.timestamp > _depositOption[sender][i].endtime){ // 超过领取的最后时间，则无法领取
                continue;
            }

            if (block.timestamp <= _depositOption[sender][i].lastime + _daySecond){ // 小于领取的开始时间，则无法领取
                continue;
            }

            uint256 option = _depositOption[sender][i].option;
            if (_depositOption[sender][i].day >= option) {  // 领取次数超过option，则领取失败
                continue;
            }

            uint256 rewardAmount = _option[option].amount;
            uint256 depositLpAmount = _depositOption[sender][i].depositAmount;
            uint256 interval = (block.timestamp - _depositOption[sender][i].lastime)/_daySecond;
            if (_depositOption[sender][i].day + interval > option){
                interval = option - _depositOption[sender][i].day;
            }
            ccbAmount = rewardAmount.mul(depositLpAmount).mul(interval).div(minerCycle).div(totalLpAmount);
            if (ccbAmount <= 0){
                continue;
            }
            _checkSurplusAmount(option, ccbAmount);
            _balanceLinearRelease[sender][i].point += ccbAmount;
            _depositOption[sender][i].lastime = _depositOption[sender][i].lastime  + interval*_daySecond; // 第二天领取时间
            _depositOption[sender][i].day += interval;
            if (_depositOption[sender][i].day == option){ //质押周期完成后，必须手动领取，随后才能线性释放
                _balanceLinearRelease[sender][i].totalReward += _balanceLinearRelease[sender][i].point;
                _balanceLinearRelease[sender][i].balance += _balanceLinearRelease[sender][i].point;
                _balanceLinearRelease[sender][i].point = 0;
                if (_balanceLinearRelease[sender][i].lastime == 0){
                    _balanceLinearRelease[sender][i].lastime = _depositOption[sender][i].startime + date*_daySecond;
                }
            }
            coppvAmount += coppvTotalAmount.mul(depositLpAmount).mul(interval).div(minerCycle).div(totalLpAmount);
        }

        // coppv
        require(coppvAmount > 0, "LP: No tokens available");
        coppvTotalAmountCopy = coppvTotalAmountCopy.sub(coppvAmount);
        IERC20(_coppv).transfer(sender, coppvAmount);
        emit WithdrawPoint(sender, ccbAmount);
    }

    function _checkSurplusAmount(uint256 option_, uint256 amount) internal {
        if (option_ == stage1){
            require(option1 > 0 && option1 >= amount, "LP: End of mining");
            option1 = option1.sub(amount);
        }
        if (option_ == stage2){
            require(option2 > 0 && option2 >= amount, "LP: End of mining");
             option2 = option1.sub(amount);
        }
        if (option_ == stage3){
            require(option3 > 0 && option3 >= amount, "LP: End of mining");
            option3 = option1.sub(amount);
        }
        if (option_ == stage4){
            require(option4 > 0 && option4 >= amount, "LP: End of mining");
            option4 = option1.sub(amount);
        }
    }

    function withdrawLinearRelease() external {
        address sender = msg.sender;
        uint256 totalAmount;
        uint256 oneAmount;
        uint256 twoAmount;
        uint256 fundAmount;
        for (uint i = 0; i < _balanceLinearRelease[sender].length; i++) {
            if (_balanceLinearRelease[sender][i].balance <= 0) {
                continue;
            }

            if (block.timestamp < _balanceLinearRelease[sender][i].lastime) {
                continue;
            }

            uint256 withdrawAmount = _balanceLinearRelease[sender][i].totalReward.mul(block.timestamp - _balanceLinearRelease[sender][i].lastime).div(releaseCycle*_daySecond);
            if (withdrawAmount <= 0) {
                continue;
            }
            if (_balanceLinearRelease[sender][i].balance < withdrawAmount){
                withdrawAmount = _balanceLinearRelease[sender][i].balance;
            }
            _balanceLinearRelease[sender][i].balance = _balanceLinearRelease[sender][i].balance.sub(withdrawAmount);
            _balanceLinearRelease[sender][i].release = _balanceLinearRelease[sender][i].release.add(withdrawAmount);
            uint256 fee1 = withdrawAmount.mul(fee1Rate).div(1000);
            uint256 fee2 = withdrawAmount.mul(fee2Rate).div(1000);
            if (_relation[sender].one != address(0)){
                oneAmount = oneAmount.add(fee1);
            } else {
                fundAmount = fundAmount.add(fee1);
            }
            if (_relation[sender].two != address(0)){
                twoAmount = twoAmount.add(fee2);
            } else {
                fundAmount = fundAmount.add(fee2);
            }
            totalAmount = totalAmount.add(withdrawAmount - fee1 - fee2);
            _balanceLinearRelease[sender][i].lastime = block.timestamp;
        }

        if (oneAmount > 0){
            IERC20(_ccb).transfer(_relation[sender].one, oneAmount);
        }

        if (twoAmount > 0){
            IERC20(_ccb).transfer(_relation[sender].two, twoAmount);
        }

        if (fundAmount > 0){
            IERC20(_ccb).transfer(fundAddress, fundAmount);
        }

        require(totalAmount > 0, "LP: No tokens available");
        IERC20(_ccb).transfer(sender, totalAmount);
        emit WithdrawLinearRelease(sender, totalAmount);
    }

    function setSecond(uint256 second_) external onlyOwner {
        _daySecond = second_;
    }

    function setDate(uint256 date_) external onlyOwner {
        date = date_;
    }

    function setMinerCycle(uint256 cycle_) external onlyOwner {
        minerCycle = cycle_;
    }

    function setReleaseCycle(uint256 cycle_) external onlyOwner {
        releaseCycle = cycle_;
    }

    function addOption1Amount(uint256 addAmount) external onlyOwner {
        option1 = option1.add(addAmount*10**_decimals);
        _option[stage1].amount = _option[stage1].amount.add(addAmount*10**_decimals);
    }

    function subOption1Amount(uint256 subAmount) external onlyOwner {
        option1 = option1.sub(subAmount*10**_decimals);
        _option[stage1].amount = _option[stage1].amount.sub(subAmount*10**_decimals);
    }

    function addOption2Amount(uint256 addAmount) external onlyOwner {
        option2 = option2.add(addAmount*10**_decimals);
        _option[stage2].amount = _option[stage2].amount.add(addAmount*10**_decimals);
    }

    function subOption2Amount(uint256 subAmount) external onlyOwner {
        option2 = option2.sub(subAmount*10**_decimals);
        _option[stage2].amount = _option[stage2].amount.sub(subAmount*10**_decimals);
    }

    function addOption3Amount(uint256 addAmount) external onlyOwner {
        option3 = option3.add(addAmount*10**_decimals);
        _option[stage3].amount = _option[stage3].amount.add(addAmount*10**_decimals);
    }

    function subOption3Amount(uint256 subAmount) external onlyOwner {
        option3 = option3.sub(subAmount*10**_decimals);
        _option[stage3].amount = _option[stage3].amount.sub(subAmount*10**_decimals);
    }

    function addOption4Amount(uint256 addAmount) external onlyOwner {
        option4 = option4.add(addAmount*10**_decimals);
        _option[stage4].amount = _option[stage4].amount.add(addAmount*10**_decimals);
    }

    function subOption4Amount(uint256 subAmount) external onlyOwner {
        option4 = option4.sub(subAmount*10**_decimals);
        _option[stage4].amount = _option[stage4].amount.sub(subAmount*10**_decimals);
    }

    function addCoppvAmount(uint256 addAmount) external onlyOwner {
        coppvTotalAmount = coppvTotalAmount.add(addAmount*10**_decimals);
        coppvTotalAmountCopy = coppvTotalAmountCopy.add(addAmount*10**_decimals);
    }

    function subCoppvAmount(uint256 subAmount) external onlyOwner {
        coppvTotalAmount = coppvTotalAmount.sub(subAmount*10**_decimals);
        coppvTotalAmountCopy = coppvTotalAmountCopy.sub(subAmount*10**_decimals);
    }
}