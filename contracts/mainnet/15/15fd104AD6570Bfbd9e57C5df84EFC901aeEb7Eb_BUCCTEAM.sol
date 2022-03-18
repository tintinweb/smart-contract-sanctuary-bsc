/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

// SPDX-License-Identifier: SimPL-2.0
pragma solidity >=0.8.0;

interface IBUCCGAME {
    function userLand(address account_) external view returns (uint256);

    function inviteCount(address account_) external view returns (uint256);

    function exchangePower(address account_, uint256 _value)
        external
        returns (bool);
}

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }
}

contract BUCCTEAM {
    address public owner;
    address public daoAddress;

    address public buccToken = 0x49aB7b384e6B7819d2e2Cb2eBD86943A865c9A7F;
    address public payToken = 0x55d398326f99059fF775485246999027B3197955; //支付token
    address public buccGame = 0x0109A80DF063413b87BED7E70af37fD32A20921A;
    address public quccAddress = 0x3c48e47703F16818d7368DBA98897FA35B80F53D;
    uint256 public burnTokenAmount = 600;

    //当期活动
    uint256 public startTime; //开始时间
    uint256 public endTime; //结束时间
    bool public activityClose = false; //活动关闭

    uint256 public basePrice = 1 * 1e18; //奖励数量=>价格
    mapping(address => bool) public whiteList;
    mapping(address => uint256) public whiteListAmount; //数量

    //用户状态
    mapping(address => bool) public userStatus; //user=>num    用户是否已兑换

    event ReceiveReward(address indexed operator, uint256 amount); // 事件

    constructor(address daoAddr_) {
        owner = msg.sender;
        daoAddress = daoAddr_;
        approveGmae(quccAddress);
    }

    function approveGmae(address _token) public {
        TransferHelper.safeApprove(_token, buccGame, ~uint256(0));
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not the owner");
        _;
    }

    function withdrawToken(address token, uint256 amount) public onlyOwner {
        TransferHelper.safeTransfer(token, daoAddress, amount);
    }

    function setOwner(address payable newAddr_) public onlyOwner {
        owner = newAddr_;
    }

    function setDao(address newAddr_) public onlyOwner {
        daoAddress = newAddr_;
    }

    function setWhiteList(
        address[] memory addrlist,
        uint256[] memory amounts,
        bool _value
    ) public onlyOwner {
        require(
            addrlist.length == amounts.length && addrlist.length > 0,
            "lsit empty error"
        );
        for (uint256 i = 0; i < addrlist.length; i++) {
            whiteList[addrlist[i]] = _value;
            whiteListAmount[addrlist[i]] = amounts[i];
        }
    }

    function setburnTokenAmount(uint256 _value) public onlyOwner {
        burnTokenAmount = _value;
    }

    function setBasePrice(uint256 _value) public onlyOwner {
        basePrice = _value;
    }

    //关闭活动
    function setActivityClose() public onlyOwner {
        activityClose = true;
    }

    function setActivityStart(uint256 startTime_, uint256 endTime_)
        public
        onlyOwner
    {
        require(block.timestamp > endTime || activityClose, "Activity started");
        activityClose = false;
        startTime = startTime_;
        endTime = endTime_;
    }

    //兑奖
    function receiveBox() public returns (bool) {
        require(block.timestamp >= startTime, "Activity not started");
        require(!activityClose && block.timestamp < endTime, "Activity ended");
        require(!userStatus[msg.sender], "Do not repeat");
        require(whiteList[msg.sender], "caller is not the white list");

        require(
            IBUCCGAME(buccGame).userLand(msg.sender) > 0,
            "land status error"
        );

        userStatus[msg.sender] = true;
        uint256 _amount = whiteListAmount[msg.sender];
        TransferHelper.safeTransferFrom(
            payToken,
            msg.sender,
            daoAddress,
            (basePrice * _amount) / 1e3
        );

        if (burnTokenAmount > 0) {
            TransferHelper.safeTransferFrom(
                quccAddress,
                msg.sender,
                address(this),
                (burnTokenAmount * _amount) / 10000
            );
        }

        IBUCCGAME(buccGame).exchangePower(msg.sender, _amount);

        emit ReceiveReward(msg.sender, _amount);
        return true;
    }
}