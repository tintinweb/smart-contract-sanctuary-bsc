pragma solidity ^0.7.0;
// SPDX-License-Identifier: SimPL-2.0
pragma experimental ABIEncoderV2;
import "./IERC20.sol";
import "./Member.sol";
import "./VerifySignature.sol";


contract TheKingToken is  Member{
    uint32 public _buyNo;
    uint32 public _blockInterval;
    uint256 public _totalSupply;
    uint256 private _buyKingTokenAmount;
    uint256 private _buyQueenToken;

    uint256 public _buyContMax;
    IERC20 public _buyTokenAddress;
    address public verify;
    event BuyKing(address, uint32);
    event AddQueen(address, address);
    event DelQueen(address, address);
    event DelUser(address, address);
    event GetInviteToken(address add,uint256 amount);

    struct users {
        bool hasKing;
        bool hasQueen;
        bool isUse;
        uint32 buyNo;
        uint256 buyKingTime;
        uint256 buyKingBlock;
    }
    struct orderInfo {
        uint32 buyNo;
        uint256 startBlock;
        uint256 colseBlock;
        address[] buyUserAddress;
        uint32 buyContNow;
    }
    mapping(uint32 => orderInfo) order;
    address[] buyUser;
    mapping(address => users) user;

    constructor(
        uint256 buyKingAmount,
        IERC20 buyToken,
        uint256 startTime,
        uint32 buyNo,
        uint256 buyCont,
        uint32 timeInterval,
        address _verify
    )  {
        _buyKingTokenAmount = buyKingAmount;
        _buyTokenAddress = buyToken;
        _buyNo = buyNo;
        _buyContMax = buyCont;
        _blockInterval = timeInterval;
        orderInfo storage _orderInfo = order[buyNo];
        _orderInfo.buyNo = buyNo;
        _orderInfo.startBlock = startTime;
        verify = _verify;


    }

    function changeBuyToken(uint256 buyKingAmount, IERC20 buyToken)
        public
        CheckPermit("Config")
    {
        _buyKingTokenAmount = buyKingAmount;
        _buyTokenAddress = buyToken;
    }

    function changeBlockInterval(uint32 timeInterval) public CheckPermit("Config") {
        _blockInterval = timeInterval;
    }

    function buyGoldKing() public {
        require(
            order[_buyNo].startBlock <= block.number,
            "Sale has not started"
        );
        require(
            order[_buyNo].buyContNow < _buyContMax,
            "This round of pre-sale has ended"
        );
        require(!user[address(msg.sender)].hasKing, "User already owns");

        if (order[_buyNo].startBlock + _blockInterval >= block.number) {
            _buyTokenAddress.transferFrom(
                address(msg.sender),
                address(this),
                _buyKingTokenAmount
            );
            users storage _user = user[address(msg.sender)];
            _user.buyKingTime = block.timestamp;
            _user.buyKingBlock = block.number;
            _user.buyNo = _buyNo;
            _user.hasKing = true;
            _user.isUse = true;
            orderInfo storage _orderInfo = order[_buyNo];
            _orderInfo.buyContNow++;
            _orderInfo.buyUserAddress.push(address(msg.sender));

            buyUser.push(address(msg.sender));
            emit BuyKing(address(msg.sender), _buyNo);
            if (_orderInfo.buyContNow == _buyContMax) {
                _buyNo++;
                _orderInfo.colseBlock = block.number;
                orderInfo storage _orderInfoNew = order[_buyNo];
                _orderInfoNew.startBlock =
                    order[_buyNo - 1].startBlock +
                    _blockInterval;
            }
        } else {
            orderInfo storage _orderInfo = order[_buyNo];
            uint32 intervalNo = uint32((order[_buyNo].startBlock + _blockInterval - 1)/_blockInterval);
            _buyNo = intervalNo;

            orderInfo storage _orderInfoNew = order[_buyNo];
            _orderInfoNew.startBlock =
                _orderInfo.startBlock +
                _blockInterval;
            buyGoldKing();
        }
    }

    function getAllToken() public CheckPermit("Admin") {
        _buyTokenAddress.transferFrom(
            address(this),
            address(msg.sender),
            _buyTokenAddress.balanceOf(address(this))
        );
    }

    function getUserInviteToken(bytes memory data)public {
        (address user, uint256 amount) = VerifySignature(verify).verifyWithdraw(data);
        require(msg.sender == user, 'invalid user');
        IERC20(_buyTokenAddress).transfer(msg.sender, amount);
        emit GetInviteToken(msg.sender,amount);
    }

    function addQueen(address _addr) public CheckPermit("Config") {
        users storage _user = user[_addr];
        _user.hasQueen = true;
        _user.isUse = true;
        emit AddQueen(address(msg.sender), _addr);
    }

    function setStartTime(uint256 startTime) public CheckPermit("Config") {
        orderInfo storage _orderInfo = order[_buyNo];
        _orderInfo.startBlock = startTime;
    }

    function delQueen(address _addr) public CheckPermit("Config") {
        require(user[_addr].isUse, "User does not exist ");
        users storage _user = user[_addr];
        _user.hasQueen = false;
        emit AddQueen(address(msg.sender), _addr);
    }

    function delUser(address _addr) public CheckPermit("Config") {
        require(user[_addr].isUse, "User does not exist ");
        users storage _user = user[_addr];
        _user.isUse = false;
        emit AddQueen(address(msg.sender), _addr);
    }

    function checkUserKing(address _addr) public view returns (bool) {
        return user[_addr].hasKing;
    }

    function checkUserQueen(address _addr) public view returns (bool) {
        return user[_addr].hasQueen;
    }

    function checkTime() public view returns (uint256) {
        return block.number;
    }

    function checkSellNo() public view returns (uint256) {
        return _buyNo;
    }

    function getMaxCont() public view returns (uint256) {
        return _buyContMax;
    }

    function getBlockInterval() public view returns (uint256) {
        uint256 timeInterval = order[_buyNo].startBlock + _blockInterval;
        return timeInterval;
    }

    function getUser(address addr) public view returns (users memory) {
        return user[addr];
    }

    function getOrderInfo(uint32 orderNo)
        public
        view
        returns (orderInfo memory)
    {
        return order[orderNo];
    }
function getChainID() external view returns (uint256) {
uint chainId; assembly { chainId := chainid() }
    return chainId;
}
}