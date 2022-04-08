/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;
interface WERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}
interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function totalSupply() external view returns (uint);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a+b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, 'sub');
        return a-b;
    }   
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {        
        return a*b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, 'div');
        return (a - (a % b)) / b;
    }    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, 'mod');
        return a % b;
    }
}
contract lp{
    using SafeMath for uint256;    
    address owner;
    address sendAddress;

    IPancakePair public payAddress; //质押币
    WERC20 outputAddress; //产出币

    struct order {
        uint256 id;
        uint256 num;
        uint256 bfs;
        uint256 status;  //1 释放 2 可领取  3已领取
        uint256 num1;
    }

    uint256 private lock = 0; 
    mapping (address => uint256) public ToReceive;  //待领取

    mapping (address => order[]) public LockList;  //质押记录


    event updateLockUpTime(uint indexed id, uint num, uint status);
    event Buy(address indexed sender, uint256 id, uint256 num, uint256 bfs, uint256 key , uint256 timestamp); 
    event Out(address indexed sender, uint256 key , uint256 timestamp); 
    constructor(IPancakePair _payAddress, WERC20 _outputAddress) {

        owner = msg.sender; //发币者
        payAddress = _payAddress;
        outputAddress = _outputAddress;
    }  
    modifier checkOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier checkSend() {
        require(msg.sender == sendAddress);
        _;
    }
    modifier checkLock() {
        require(lock == 0);
        lock = 1;
        _;
        lock = 0;
    }
    //质押
    function buy(uint256 id, uint256 _num) checkLock public{
        require(id > 0);
        require(_num > 0);
        (bool success, bytes memory returndata) = address(payAddress).call{ value: 0 }(abi.encodeWithSelector(payAddress.transferFrom.selector, msg.sender,address(this), _num));  
        if (!success) {
            if (returndata.length > 0) {               
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert('no error');
            }
        } 
        (uint112 _balance0, uint112 _balance1, uint112 _blockTimestampLast) = payAddress.getReserves();
        _balance0 = 0;
        _blockTimestampLast = 0;
        uint256 _totalSupply = payAddress.totalSupply();
        uint256 bfs = _num.mul(_balance1) / _totalSupply;
       
        uint key = LockList[msg.sender].length+1;
        LockList[msg.sender].push(order(key,_num,bfs,1,0));
        emit Buy(msg.sender,id,_num, bfs, key, block.timestamp);
    }
    //领取质押
    function out(uint256 id, address to) public{
        uint256 _index = id.sub(1); 
        uint256 status = LockList[msg.sender][_index].status;
        require(status == 2, "Do not pick up");
        uint256 _num = LockList[msg.sender][_index].num1;
        (bool success, bytes memory returndata) = address(payAddress).call{ value: 0 }(abi.encodeWithSelector(payAddress.transfer.selector, to, _num));  
        if (!success) {
            if (returndata.length > 0) {               
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert('no error');
            }
        } 
        LockList[msg.sender][_index].status = 3;
        emit Out(msg.sender,id, block.timestamp);
    }
    //用户领取
    function receiveReward() public {
        uint256 num = ToReceive[msg.sender];
        require(num > 0 ,'no bfs'); 
        (bool success, bytes memory returndata) = address(outputAddress).call{ value: 0 }(abi.encodeWithSelector(outputAddress.transfer.selector, msg.sender, num));  
        if (!success) {
            if (returndata.length > 0) {               
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert('no error');
            }
        } 
        ToReceive[msg.sender] = 0;
    }
    //提现合约代币
    function withdraw(WERC20 erc20address, uint256 num, address _to) checkOwner public {
        (bool success, bytes memory returndata) = address(erc20address).call{ value: 0 }(abi.encodeWithSelector(erc20address.transfer.selector, _to, num));  
        if (!success) {
            if (returndata.length > 0) {               
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert('no error');
            }
        } 
    }
    //通知佣金
    function updateWaitReceive(address _u,uint _a, uint256 _t) checkSend public {
        if(_t == 1){
            ToReceive[_u] = ToReceive[_u].add(_a);
        }else if(_t == 2){
            ToReceive[_u] = ToReceive[_u].sub(_a);
        }
    }
    //通知lp
    function updateWaitReceiveLp(address _a, uint _key, uint _s, uint _n1) checkSend public {
        uint256 _index = _key.sub(1); 
        LockList[_a][_index].status = _s;
        LockList[_a][_index].num1 = _n1;
    }
    //修改发币者
    function setOwner(address _a) checkOwner public {
        owner = _a;
    }
    function setSendAddress(address _a) checkOwner public {
        sendAddress = _a;
    }
}