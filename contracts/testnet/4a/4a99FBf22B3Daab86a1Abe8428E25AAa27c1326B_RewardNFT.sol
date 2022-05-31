// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./IERC721.sol";

contract RewardNFT is Ownable,ReentrancyGuard{
    using SafeMath for uint256;

    uint256 public holdTime = 604800 ;// 7*24*3600

    // TACqoNBnAMZmze97KdBibRoQGkS3St875X  0x02942010Fa6bAA020A2a53661B2fda1CfBFD9777
    //address public nftAddress = address(0x02942010Fa6bAA020A2a53661B2fda1CfBFD9777);

    address public nftAddress = address(0x097D054837B98FCa1bb1600817c70514bd7d7887); //BSC-TEST

    uint256 public hadIssueNums;

    struct OrderPacket {
        address addr;
        uint256 timestamp;
        uint256 tbFirstAmount;
        uint256 issueStatus;  //1存在订单，2已发放
    }
    mapping(address => OrderPacket) public orderPacketMap;
    address[] public orderList;
    address[] public hadIssueAddress;


    mapping(address => bool) public operators;

    modifier onlyOperator() {
        require(operators[msg.sender], "Operator: caller is not the operator");
        _;
    }

    event PushEvent(address indexed addr);
    event DelEvent(address indexed addr);

    event addRewardNftInfoEvent(
            address indexed buyAddress,
            uint256 timestamp,
            uint256 amount,
            bool isOk
     );

    constructor() {
        operators[msg.sender] = true;
    }

    receive() external payable {  }

    function getOrderListLength() public view returns (uint256){
        return orderList.length;
    }

    function setOperator(address _operator, bool _enabled) public onlyOwner {
        operators[_operator] = _enabled;
    }

    function updateNftAddress(address newAddress) external onlyOwner{
        nftAddress = newAddress;
        
    }


    function addRewardNftInfo(address _buyAddress, uint256 _timestamp, uint256 _amount,bool isOk) public nonReentrant onlyOperator {
        OrderPacket storage order = orderPacketMap[_buyAddress];
        if (order.issueStatus == 0){
            if (isOk){
                OrderPacket memory orderx = OrderPacket(
                    _buyAddress,
                    _timestamp,
                    _amount,
                    1
                );
                orderPacketMap[_buyAddress] = orderx;
                orderList.push(_buyAddress);
                emit PushEvent(_buyAddress);
            }
        }else  if (order.issueStatus == 1){
            if (order.timestamp.add(holdTime) <= block.timestamp) {
                if(_amount < order.tbFirstAmount){
                    delete orderPacketMap[_buyAddress];
                    emit DelEvent(_buyAddress);
                }
            }
        }else{
            //奖励过了，不再奖励NFT了
        }

        emit addRewardNftInfoEvent(_buyAddress,  _timestamp,  _amount, isOk);
    }
    

    function issueRewardNft(address nftHolderAddress, address addr, uint256 tokenId) public nonReentrant onlyOperator {
        OrderPacket storage order = orderPacketMap[addr];
        require(order.issueStatus> 1, "order issueStatus must eq 1");
        require(order.timestamp.add(holdTime) > block.timestamp, "order must hold enough time");

       require(IERC721(nftAddress).ownerOf(tokenId) == nftHolderAddress, "not nftHolderAddress owner");

        order.issueStatus = 2;
        hadIssueNums++;
 
        IERC721(nftAddress).safeTransferFrom(nftHolderAddress, addr, tokenId);
        hadIssueAddress.push(addr);
    }
}