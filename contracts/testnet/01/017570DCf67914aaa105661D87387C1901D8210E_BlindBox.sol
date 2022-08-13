/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

pragma solidity =0.6.6;
pragma experimental ABIEncoderV2;

// safe math
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Math error");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >= b, "Math error");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "Math error");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a / b;
        return c;
    }
}


// erc20
interface IERC20 {
    function balanceOf(address _address) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// safe transfer
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        // (bool success,) = to.call.value(value)(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


// owner
contract Ownable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, 'BlindBox: owner error');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


// Burn ETT
contract BlindBox is Ownable {
    using SafeMath for uint256;
    address private zeroAddress = address(0);  // 销毁收币地址
    uint256 private everyDaySecond = 10;       // 86400 // 不同比例的秒，测试网10，主网86400
    uint256 private day100 = 100;              // 100次(everyDaySecond)释放完成
    address public ett;  // ett代币地址
    bool public isOpen;  // 销毁活动是否开启===========================
    uint256 public totalAmount; // 总的销毁数量========================

    mapping(address => amountToDay[]) private userAmountToDays; // 用户全部的销毁记录
    struct amountToDay{
        uint256 amount;        // 销毁的数量
        uint256 startTime;     // 开始的时间
        uint256 takeAmount;    // 领走的数量
        uint256 allTakeAmount; // 可领走的总量
    }
    mapping(address => uint256) public burnAmount; // 用户销毁总量=======================



    constructor(address _owner, address _ett) public {
        owner = _owner;
        ett = _ett;
    }

    // set open
    function setIeOpen() public onlyOwner{
        isOpen = !isOpen;
    }

    // user burn ett; 用户销毁ETHH=========================================
    function userBurn(uint256 _amount) public {
        require(isOpen, "already over");
        require(_amount > 0, "value error");
        TransferHelper.safeTransferFrom(ett, msg.sender, zeroAddress, _amount);

        userAmountToDays[msg.sender].push(amountToDay(_amount, block.timestamp, 0, _amount.mul(2)));
        burnAmount[msg.sender] = burnAmount[msg.sender].add(_amount);
        totalAmount = totalAmount.add(_amount);
    }

    // can take single; 计算单个销毁订单可以领取的数量
    function canTake(address _user, uint256 _index) private view returns(uint256 _value) {
        if(userAmountToDays[_user].length <= _index) {
            return 0;
        }

        // 获取某个销毁单进行计算
        amountToDay memory _data = userAmountToDays[_user][_index];
        // 计算共可以领取的数量
        uint256 _day = (block.timestamp - _data.startTime).div(everyDaySecond);
        if(_day == 0) {
            return 0;
        }
        uint256 _canTake = _data.allTakeAmount.mul(_day).div(day100);
        _canTake = _canTake >= _data.allTakeAmount ? _data.allTakeAmount : _canTake;

        _value = _canTake.sub(_data.takeAmount);
    }
    // 处理单个销毁订单的数据
    function canTakeV2(address _user, uint256 _index) private returns(uint256 _value) {
        if(userAmountToDays[_user].length <= _index) {
            return 0;
        }

        // 获取某个销毁单进行计算
        amountToDay storage _data = userAmountToDays[_user][_index];
        // 计算共可以领取的数量
        uint256 _day = (block.timestamp - _data.startTime).div(everyDaySecond);
        if(_day == 0) {
            return 0;
        }
        uint256 _canTake = _data.allTakeAmount.mul(_day).div(day100);
        _canTake = _canTake >= _data.allTakeAmount ? _data.allTakeAmount : _canTake;

        _value = _canTake.sub(_data.takeAmount);
        _data.takeAmount = _data.takeAmount.add(_value);
    }

    // can take all; 计算用户全部订单当前时间可以领取的数量===================================
    function canTakes(address _user) public view returns(uint256 _value) {
        uint256 _length = userAmountToDays[_user].length;
        uint256 _r;
        for(uint256 i = 0; i < _length; i++) {
            _r = canTake(_user, i);
            _value = _value.add(_r);
        }
    }
    // 处理全部订单
    function canTakesV2(address _user) private returns(uint256 _value) {
        uint256 _length = userAmountToDays[_user].length;
        uint256 _r;
        for(uint256 i = 0; i < _length; i++) {
            _r = canTakeV2(_user, i);
            _value = _value.add(_r);
        }
    }

    // take; 用户领取收益=============================================
    function take() public {
        uint256 _value = canTakesV2(msg.sender);
        if(_value == 0) return;

        TransferHelper.safeTransfer(ett, msg.sender, _value);
    }

    // get all burn; // 获取全部的销毁订单
    function getUsetBurns(address _user) public view returns(amountToDay[] memory _r) {
        uint256 _length = userAmountToDays[_user].length;
        _r = new amountToDay[](_length);
        for(uint256 i = 0; i < _length; i++){
            _r[i] = userAmountToDays[_user][i];
        }
    }







}