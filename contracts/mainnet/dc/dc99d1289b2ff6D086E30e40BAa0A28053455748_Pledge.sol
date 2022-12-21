/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

pragma solidity 0.8.13;
// SPDX-License-Identifier: MIT

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;  
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

    uint public constant SECONDS_PER_DAY = 24 * 60 * 60;
 
    address private owner;
    
    mapping(address => PledgeOrder) public _orders;

    ERC20 public _PledgeToken = ERC20(0x74bf8B1e69DD70b03C43fb7506EC4580cf7C1C73);

    address public zero = 0x000000000000000000000000000000000000dEaD;
    address public one = 0x74bf8B1e69DD70b03C43fb7506EC4580cf7C1C73;

    uint256 public _Fee = 6;
    uint256 public _referFee = 330;
    uint256 public _holdFee = 20;
    uint256 public _funFee = 40;
    uint256 public _maxPladge = 888 * 10 ** 18;
    uint256 public _referPladge = 200 * 10 ** 18;

    mapping(address => address) public recommendList;
 

    struct PledgeOrder {
        bool isExist;
        uint256 lastTime;
        uint256 receiveAmount;
        uint256 totalAmount;
    }
 
    constructor () public{
        owner = msg.sender;
    }
	
    function pledgeToken(uint256 _amount) public{
        require(_amount > 0, "amount too little");
        require(address(msg.sender) == address(tx.origin), "no contract");
		_PledgeToken.transferFrom(msg.sender, address(this), _amount);
        if(_orders[msg.sender].isExist == false){
            createOrder(_amount);
        }else{
            PledgeOrder storage order = _orders[msg.sender];
            require(order.totalAmount + _amount <= _maxPladge, "pledge upper limit");

            order.totalAmount += _amount;
        }

    }
 
    function createOrder(uint256 trcAmount) private {
        _orders[msg.sender] = PledgeOrder(
            true,
            block.timestamp,
            0,
            trcAmount
        );
    }

    function takeProfit() public {
        require(address(msg.sender) == address(tx.origin), "no contract");
        PledgeOrder storage order = _orders[msg.sender];
        uint256 day = (block.timestamp - order.lastTime) / SECONDS_PER_DAY;
        require(day > 0 || order.receiveAmount > 0, "no reward");
        uint256 pledgeBalance = _PledgeToken.balanceOf(address(this));

        uint256 profits = order.totalAmount * _Fee / 1000 * day;
        
        if(order.totalAmount >= _referPladge){
            address rec1 = recommendList[msg.sender];
            if(rec1 != address(0)){
                PledgeOrder storage order1 = _orders[rec1];
                if(order1.isExist){
                    order1.receiveAmount += profits * _referFee / 1000;
                }
            }
        }

        require(pledgeBalance >= profits, "contract no balance");
        _PledgeToken.safeTransfer(address(msg.sender), profits);
        order.lastTime = block.timestamp;
    }

    function takeReferProfit() public {
        require(address(msg.sender) == address(tx.origin), "no contract");
        PledgeOrder storage order = _orders[msg.sender];
        uint256 pledgeBalance = _PledgeToken.balanceOf(address(this));
        uint256 profit = order.receiveAmount;

        require(pledgeBalance >= profit, "contract no balance");
        order.receiveAmount = 0;
        
        _PledgeToken.safeTransfer(address(msg.sender), profit);
        
    }


    function takePledge() public {
        require(address(msg.sender) == address(tx.origin), "no contract");
        PledgeOrder storage order = _orders[msg.sender];
        uint256 pledgeBalance = _PledgeToken.balanceOf(address(this));
        uint256 profit = order.totalAmount;

        require(pledgeBalance >= profit, "contract no balance");
        order.totalAmount = 0;
        _PledgeToken.safeTransfer(zero, profit * 20 / 1000);
        _PledgeToken.safeTransfer(address(msg.sender), profit * 940 / 1000);
        _PledgeToken.safeTransfer(one, profit * 40 / 1000);
        
    }

    function getParentProfitToken(address _target) public view returns(uint256) {
        require(address(msg.sender) == address(tx.origin), "no contract");
        PledgeOrder memory order = _orders[_target];
        uint256 day = (block.timestamp - order.lastTime) / SECONDS_PER_DAY;
        uint256 profits = order.totalAmount * _Fee / 1000 * day;
        return profits;
    }


    function getPledge(address _target) public view returns(uint256) {
        require(address(msg.sender) == address(tx.origin), "no contract");
        PledgeOrder memory order = _orders[_target];
        return order.totalAmount;
    }


    function getUpPledge(address _target) public view returns(uint256) {
        require(address(msg.sender) == address(tx.origin), "no contract");
        PledgeOrder memory order = _orders[_target];
        return order.receiveAmount;
    }

    function getPledgeTime(address _target) public view returns(uint256) {
        require(address(msg.sender) == address(tx.origin), "no contract");
        PledgeOrder memory order = _orders[_target];
        return order.lastTime;
    }

    function changeOwner(address paramOwner) public onlyOwner {
		owner = paramOwner;
    }


    function withdraw(address _token, address _target, uint256 _amount) public onlyOwner {
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