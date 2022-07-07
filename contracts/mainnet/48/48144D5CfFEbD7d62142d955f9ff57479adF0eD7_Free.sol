/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.15;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
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
}

contract Free is ERC20Detailed, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    string public _name = "Adam Protocol";
    string public _symbol = "ADAM";
    uint8 public _decimals = 8;
    //代币总量
    uint256 _initSupply = 61000000;
    //精度
    uint256 public constant DECIMALS = 18;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 8;

    IERC20 public USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
    IERC20 public LP;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    //卖出生态钱包
    address public marketAddress = 0xC4e339d96fA6ca6e942443971E93273BC7D3D7aE;

    address public pair;

    uint256 public TOTAL_GONS;
    uint256 public constant MAX_SUPPLY =~uint128(0)/1e14;
    uint256 public _totalSupply;
    uint256 public _gonsPerFragment;
    uint256 public pairBalance;
    //最后一次复利时间
    uint256 public _lastRebasedTime;
    //发币时间
    uint256 public _baseTime;
    //当前ido总量
    uint256 public idoTotal;
    //ido开关 true开启
    bool public idoEnable = true;
    //复利开关
    bool public rebaseEnable = true;
    //lp质押总额
    uint256 public totalLpPledge;
    //lp质押金额
    mapping(address => uint256) public _lpAmount;
    mapping(address => uint256) public _gonBalances;
    mapping(address => mapping(address => uint256)) public _allowedFragments;
    mapping(address => IdoOrder) public _orders;
    mapping(address => LpOrder) public _LpOrders;
    //推荐人信息
    mapping(address => address)public commond;
    //ido推荐人信息
    mapping(address => address)public idoCommond;
    //收益领取状态
    mapping(address => bool)public profitStatus;
    //lp分红地址组
    address[] lpProfitList;
    //当前lp奖励金额
    uint256 public currentReward = 0;

    //ido标记 ido总额 剩余金额
    struct IdoOrder {
        bool isExist;
        uint256 lastTime;
        uint256 totalAmount;
        uint256 rewardAmount;
    }

    //lp标记 lp总额
    struct LpOrder {
        bool isExist;
        uint256 amount;
    }
    
    constructor() ERC20Detailed(_name,_symbol, uint8(DECIMALS)) Ownable() {
        _totalSupply = _initSupply * 10 ** DECIMALS;
        TOTAL_GONS =
        MAX_UINT256/1e10 - (MAX_UINT256/1e10 % _totalSupply);
        _gonBalances[msg.sender] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = block.timestamp;
        _baseTime = block.timestamp;
       
        emit Transfer(address(0x0), msg.sender, _totalSupply);
    }

    function ido(uint256 _amount) public{
        require(_amount >= 100 * 10 ** 18 && _amount <= 500 * 10 ** 18 , "amount error");
        require(address(msg.sender) == address(tx.origin), "no contract");
        require(_amount % 100 * 10 ** 18 == 0, "amount false");
        require(idoEnable, "ido off");
        USDT.approve(address(this), _amount);
        USDT.transferFrom(msg.sender, address(this), _amount);
        uint256 _day = (block.timestamp - _baseTime) / 1 days;
        if(_day >= 30){
            _basicTransfer(address(this), DEAD, _totalSupply - idoTotal);
            idoEnable = false;
            return;
        }
        uint256 _price = 100 + (2 * _day);
        uint256 _amounts = _amount * _price / 1000;
        require(balanceOf(address(this)) >= _amounts, "contract balance insufficient");
        require(idoTotal <= _totalSupply * 8 / 10, "Ido has reached the upper limit");
        if(_orders[msg.sender].isExist == false){
            createOrder(_amounts);
        }else{
            IdoOrder storage order=_orders[msg.sender];

            order.totalAmount += _amounts;
            order.rewardAmount += _amounts * 99 / 100;
        }
        _basicTransfer(address(this), msg.sender, _amounts / 100);
        idoTotal += _amounts;
        bouns(_amount);
    }
    //当前ido价格
    function getIdoPrice() view external returns(uint256){
        uint256 _day = (block.timestamp - _baseTime) / 1 days;
        return (100 + (2 * _day)) ;
    }

    //分发收益
    function bouns(uint256 _amount) internal {
        address top1 = idoCommond[msg.sender];
        if(top1 != address(0)){
            USDT.transferFrom(address(this), top1, _amount * 6 / 100);
            top1 = idoCommond[msg.sender];
            if(top1 != address(0)){
                USDT.transferFrom(address(this), top1, _amount * 4 / 100);
                top1 = idoCommond[top1];
                if(top1 != address(0)){
                    USDT.transferFrom(address(this), top1, _amount * 2 / 100);
                }
            }
        }
    }

    function createOrder(uint256 trcAmount) private {
        _orders[msg.sender] = IdoOrder(
            true,
            block.timestamp,
            trcAmount,
            trcAmount * 99 / 100
        );
    }

    //lp质押
    function lpPledge(uint256 _amount) public{
        LP.transferFrom(msg.sender, address(this), _amount);
        if(_LpOrders[msg.sender].isExist == false){
            createLpOrder(_amount);
            lpProfitList.push(msg.sender);
        }else{
            LpOrder storage order = _LpOrders[msg.sender];
            order.amount += _amount;
        }
        totalLpPledge += _amount;
    }

    function createLpOrder(uint256 trcAmount) private {
        _LpOrders[msg.sender] = LpOrder(
            true,
            trcAmount
        );
    }

    //ido提取
    function withdrawIDo() external {
        IdoOrder storage order = _orders[msg.sender];
        require(order.rewardAmount > 0, "amount insufficient");
        uint256 amount = order.rewardAmount;
        order.rewardAmount = 0;
        _basicTransfer(address(this), msg.sender, amount);
    }


    //lp提取
    function withdrawLp() external {
        LpOrder storage order = _LpOrders[msg.sender];
        require(order.amount > 0, "amount insufficient");
        uint256 amount = order.amount;
        order.amount = 0;
        totalLpPledge -= amount;
        LP.transfer(msg.sender, amount);
    }


    //管理员发放lp收益次数
    function doProfit() external onlyOwner{
        uint256 pledgeBalance = LP.balanceOf(address(this));
        require(pledgeBalance > 0, "no balance");
        currentReward = pledgeBalance;

        for(uint i = 0; i < lpProfitList.length; i++) {
            profitStatus[lpProfitList[i]] = true;
        }
    }

    //领取lp分红
    function getLpProfit() external {
        require(address(msg.sender) == address(tx.origin), "no contract");
        require(profitStatus[msg.sender], "no reward");
        LpOrder storage order = _LpOrders[msg.sender];
        uint256 reward = order.amount / totalLpPledge * currentReward;
        profitStatus[msg.sender] = false;
        _basicTransfer(address(this), msg.sender, reward);
    }

    //查询lp分红
    function queryLpProfit() view external returns(uint256){
        require(address(msg.sender) == address(tx.origin), "no contract");
        require(profitStatus[msg.sender], "no reward");
        LpOrder storage order = _LpOrders[msg.sender];
        return order.amount / totalLpPledge * currentReward;
    }

    function manualRebase() external{
        require(shouldRebase(),"rebase not required");
        rebase();
    }

    function shouldRebase() internal view returns (bool) {
        return
        (_totalSupply < MAX_SUPPLY) &&
        msg.sender != pair  &&
        block.timestamp >= (_lastRebasedTime + 1 days);
    }

    //复利
    function rebase() internal {
        require(rebaseEnable, "no open");

        uint256 rebaseRate = 2000000;
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(1 days);

        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
            .mul((10 ** RATE_DECIMALS).add(rebaseRate))
            .div(10 ** RATE_DECIMALS);
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(1 days));

    }
  
    function transfer(address to, uint256 value)
    external
    override
    returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {

        _allowedFragments[from][msg.sender] = _allowedFragments[from][
        msg.sender
        ].sub(value, "Insufficient Allowance");
        _transferFrom(from, to, value);
        return true;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);
        emit Transfer(from, to, amount);
        return true;
    }

    function add_next_add(address recipient)private{
        if(commond[recipient] == address(0)){
            if(msg.sender == pair)return;
            commond[recipient] = msg.sender;
        }
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if(amount >= 1 * 10 ** DECIMALS){
            add_next_add(recipient);
        }
        if (shouldRebase()) {
            rebase();
        }
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        if (sender == pair){
            pairBalance = pairBalance.sub(amount);
        }else{
            _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        }
        uint256 gonAmountReceived = takeFee(sender, recipient, gonAmount);

        if (recipient == pair){
            pairBalance = pairBalance.add(gonAmountReceived.div(_gonsPerFragment));
        }else{
            _gonBalances[recipient] = _gonBalances[recipient].add(
                gonAmountReceived
            );
        }

        emit Transfer(sender, recipient, gonAmountReceived.div(_gonsPerFragment));
        return true;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) internal  returns (uint256) {
        uint256 feeAmount;
        uint256 shareAmount = 0;
        if (sender == pair) {
            uint256 lpAmount = gonAmount * 4 / 100;
            _gonBalances[address(this)] = _gonBalances[address(this)].add(lpAmount);
            emit Transfer(sender, address(this), lpAmount.div(_gonsPerFragment));

            shareAmount = gonAmount * 8 / 100;
            address _sender = tx.origin;
            address pre = commond[_sender];
            uint total = shareAmount;
            uint a;
            if(pre!=address(0) && balanceOf(pre) >= 1000 * 10 ** DECIMALS){
                a = shareAmount*3/8;_gonBalances[pre]+=a;total-=a;emit Transfer(_sender, pre, a.div(_gonsPerFragment));pre=commond[pre];
            }if(pre!=address(0) && balanceOf(pre) >= 1000 * 10 ** DECIMALS){
                a = shareAmount/4;_gonBalances[pre]+=a;total-=a;emit Transfer(_sender, pre, a.div(_gonsPerFragment));pre=commond[pre];
            }if(pre!=address(0) && balanceOf(pre) >= 1000 * 10 ** DECIMALS){
                a = shareAmount/16;_gonBalances[pre]+=a;total-=a;emit Transfer(_sender, pre, a.div(_gonsPerFragment).div(_gonsPerFragment));pre=commond[pre];
            }if(pre!=address(0) && balanceOf(pre) >= 1000 * 10 ** DECIMALS){
                a = shareAmount/16;_gonBalances[pre]+=a;total-=a;emit Transfer(_sender, pre, a);pre=commond[pre];
            }if(pre!=address(0) && balanceOf(pre) >= 1000 * 10 ** DECIMALS){
                a = shareAmount/16;_gonBalances[pre]+=a;total-=a;emit Transfer(_sender, pre, a.div(_gonsPerFragment));pre=commond[pre];
            }if(pre!=address(0) && balanceOf(pre) >= 1000 * 10 ** DECIMALS){
                a = shareAmount/16;_gonBalances[pre]+=a;total-=a;emit Transfer(_sender, pre, a.div(_gonsPerFragment));pre=commond[pre];
            }if(pre!=address(0) && balanceOf(pre) >= 1000 * 10 ** DECIMALS){
                a = shareAmount/16;_gonBalances[pre]+=a;total-=a;emit Transfer(_sender, pre, a.div(_gonsPerFragment));pre=commond[pre];
            }if(pre!=address(0) && balanceOf(pre) >= 1000 * 10 ** DECIMALS){
                a = shareAmount/16;_gonBalances[pre]+=a;total-=a;emit Transfer(_sender, pre, a.div(_gonsPerFragment));pre=commond[pre];
            }if(total!=0){
                _gonBalances[marketAddress] += total;
                emit Transfer(_sender, marketAddress, total.div(_gonsPerFragment));
            }

            feeAmount = feeAmount + lpAmount + shareAmount;
        }
        if (recipient == pair) {
            uint256 deadAmount = gonAmount * 8 / 100;
            _gonBalances[DEAD] = _gonBalances[DEAD].add(deadAmount);
            emit Transfer(sender, DEAD, deadAmount.div(_gonsPerFragment));

            uint256 marketAmount = gonAmount * 4 / 100;
            _gonBalances[marketAddress] = _gonBalances[marketAddress].add(marketAmount);
            emit Transfer(sender, marketAddress, marketAmount.div(_gonsPerFragment));

            feeAmount = feeAmount + deadAmount + marketAmount + shareAmount;
        }

        return gonAmount.sub(feeAmount);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address who) public view override returns (uint256) {
        if (who == pair){
            return pairBalance;
        }else{
            return _gonBalances[who].div(_gonsPerFragment);
        }
    }
    function allowance(address owner_, address spender)
    external
    view
    override
    returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }
    function approve(address spender, uint256 value)
    external
    override
    returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function setPair(address _target, uint256 _amount) public onlyOwner{
        pair = _target;
        pairBalance = _amount * 10 ** DECIMALS;
    }

    //复利开关设置
    function setRebaseEnable(bool _target) public onlyOwner{
        rebaseEnable = _target;
    }

    //推荐人绑定
    function bind(address _target) external{
        idoCommond[msg.sender] = _target;
    }

    //查询推荐人
    function getRecommend(address _address) view external returns(address){
        return idoCommond[_address];
    }
    
    //设置lp地址
    function setLpToken(address _lpAddress) external onlyOwner{
        LP = IERC20(_lpAddress);
    }

    //设置usdt地址
    function setUSDTToken(address _uAddress) external onlyOwner{
        USDT = IERC20(_uAddress);
    }
    //代币提现
    function withdraw(address _token, address _target, uint256 _amount) external onlyOwner {
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "no balance");
		IERC20(_token).transfer(_target, _amount);
    }

}