/**
 *Submitted for verification at BscScan.com on 2022-06-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

pragma solidity 0.8.13;
// SPDX-License-Identifier: MIT

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        // 空字符串hash值
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;  
        //内联编译（inline assembly）语言，是用一种非常底层的方式来访问EVM
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
}

library SafeERC20 {
    using Address for address;
 
    function safeTransfer(ERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
 
    function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
 
    function safeApprove(ERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),"SafeERC20: approve from non-zero to non-zero allowance");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
 
    function callOptionalReturn(ERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
 
interface ERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
 
contract Pledge {
    using SafeERC20 for ERC20;

    address private owner;
    
    mapping(address => PledgeOrder) public _orders;

    //a代币合约地址 旧币
    ERC20 public _PledgeToken = ERC20(0x398fC16AC7FE2B3C32eB43C3B8CD2F09155f57dB);

    //千分之5收益
    uint256 public _rewardFee = 5;
    
    //当前发放次数
    uint256 public _currentRewardNum = 0;

    //发放次数
    uint256 public _rewardNum = 200;

    //质押总额
    uint256 public _pledgeTotalAmount = 0;
    
    //质押上限
    uint256 public _maxAmount = 25000000 * 10 ** 18;
    
    //质押基数
    uint256 public _pledgeNumber = 100;

    //当前空投数量
    uint256 public _aridropAmount = 0;

    //质押开关
    bool public _pledgeEnable = true;


    mapping(address => address) public recommendList;

    mapping(address => bool) public blackList;

    address[] _users; 
 

    //是否存在质押记录 已领取奖励次数 质押总额 空投领取次数
    struct PledgeOrder {
        bool isExist;
        uint256 receiveNum;
        uint256 totalAmount;
        bool airdropEnable;
    }
 
    constructor () {
        owner = msg.sender;
    }
	
	//质押代币
	//质押之前需要先调用其合约的approve方法 获取授权
    function pledgeToken(uint256 _amount) public{
        require(_pledgeEnable, "no start");
        require(_amount % _pledgeNumber == 0, "amount error");
        require(_pledgeTotalAmount + _amount <= _maxAmount, "amount too much");
        require(address(msg.sender) == address(tx.origin), "no contract");
		_PledgeToken.transferFrom(msg.sender, address(this), _amount);
        if(_orders[msg.sender].isExist == false){
            createOrder(_amount);
        }else{
            PledgeOrder storage order=_orders[msg.sender];
            order.totalAmount = order.totalAmount + _amount;
        }
        _pledgeTotalAmount += _amount;
        uint256 balance = _PledgeToken.balanceOf(address(this));
        if(balance > _amount / 10){
            address top = recommendList[msg.sender];
            if(top != address(0)){
                _PledgeToken.safeTransfer(top, _amount * 10 / 100);
                top = recommendList[top];
                if(top != address(0)){
                    _PledgeToken.safeTransfer(top, _amount * 4 / 100);
                    top = recommendList[top];
                    for(int i = 0; i < 8; i ++){
                        if(top != address(0)){
                            _PledgeToken.safeTransfer(top, _amount * 5 / 1000);
                            top = recommendList[top];
                        }
                    }
                }
            }
        }
    }
 
    function createOrder(uint256 trcAmount) private {
        _orders[msg.sender] = PledgeOrder(
            true,
            _currentRewardNum,
            trcAmount,
            false
        );
        _users.push(msg.sender);
    }

    //管理员发放收益
    function doReward() external onlyOwner {
        _currentRewardNum ++;
    }

	//提取收益
    function takeProfit() public {
        require(blackList[msg.sender] == false, "is black");
        require(address(msg.sender) == address(tx.origin), "no contract");
        PledgeOrder storage order = _orders[msg.sender];
        uint256 number = _currentRewardNum - order.receiveNum;
        require(number > 0, "no reward");
        require(order.receiveNum < _rewardNum, "reveive too much");
        uint256 pledgeBalance = _PledgeToken.balanceOf(address(this));

        // 质押数量 * 奖励费率 * 奖励次数
        uint256 profits = order.totalAmount * _rewardFee / 500 * number;

        require(pledgeBalance >= profits, "no balance");
        _PledgeToken.safeTransfer(address(msg.sender), profits);

        order.receiveNum += number;
    }

	//查询收益
    function getParentProfitToken(address _target) external view returns(uint256) {
        require(address(msg.sender) == address(tx.origin), "no contract");
        PledgeOrder memory order = _orders[_target];
        uint256 number = _currentRewardNum - order.receiveNum;
        uint256 profits = order.totalAmount * _rewardFee / 500 * number;
        return profits;
    }
    
	//管理员空投
    function doAirdrop(uint256 _amount) external onlyOwner {
        uint256 pledgeBalance = _PledgeToken.balanceOf(address(this));
        require(_amount <= pledgeBalance, "no balance");
        _aridropAmount = _amount;

        for(uint i = 0; i < _users.length; i++) {
            PledgeOrder memory order = _orders[_users[i]];
            order.airdropEnable = true;
        }

    }

    //查询空投收益
    function getAirdropProfit(address _target) external view returns(uint256) {
        require(address(msg.sender) == address(tx.origin), "no contract");
        PledgeOrder memory order = _orders[_target];
        require(order.airdropEnable, "no reward");
        uint256 profits = order.totalAmount * _aridropAmount / _pledgeTotalAmount;
        return profits;
    }

    //提取空投收益
    function takeAirdrop() public {
        require(blackList[msg.sender] == false, "is black");
        require(address(msg.sender) == address(tx.origin), "no contract");
        PledgeOrder storage order = _orders[msg.sender];
        require(order.airdropEnable, "no reward");
        uint256 pledgeBalance = _PledgeToken.balanceOf(address(this));

        // 质押数量 * 奖励费率 * 奖励次数
        uint256 profits = order.totalAmount * _aridropAmount / _pledgeTotalAmount;

        require(pledgeBalance >= profits, "no balance");
        _PledgeToken.safeTransfer(address(msg.sender), profits);

        order.airdropEnable = false;

    }
    
	//加入/移除黑名单
    function setBlackList(address _target, bool _status) external onlyOwner {
        blackList[_target] = _status;
    }

    function changeOwner(address paramOwner) public onlyOwner {
		owner = paramOwner;
    }

    //修改收益费率
    function setRewardFee(uint256 _fee) public onlyOwner {
		_rewardFee = _fee;
    }

    //修改收益发放次数
    function setRewardNumber(uint256 _target) public onlyOwner {
		_rewardNum = _target;
    }
    
    //修改质押基数
    function setPledgeNumber(uint256 _target) public onlyOwner {
		_pledgeNumber = _target;
    }
    
    //修改质押开关
    function setPledgeEnable(bool _target) public onlyOwner {
		_pledgeEnable = _target;
    }

    function withdraw(address _token, address _target, uint256 _amount) external onlyOwner {
        require(ERC20(_token).balanceOf(address(this)) >= _amount, "no balance");
		ERC20(_token).safeTransfer(_target, _amount);
    }


    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
 
    function getOwner() public view returns (address) {
        return owner;
    }

    function bind(address _target) public {
        recommendList[msg.sender] = _target;
    }
}