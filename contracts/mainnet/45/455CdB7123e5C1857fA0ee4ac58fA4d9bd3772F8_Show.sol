//SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./ERC721Enumerable.sol";


interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IFreeper{
    function getTokenIdCreator(uint tokenId) external view returns(address);
    function isVerifiedUser(address addr) external view returns(bool);
    function getPublishDomainId(address addr) external view returns (uint);
    function insert(uint tokenId, uint amount) external;
}



contract Show is Ownable{
    using SafeMath for uint256;

    address public feeAddress;
    address public usdtAddress;
    address public freeperAddress;
    address public poolAddress;

    uint createFeeRate = 200;
    uint joinFeeRate = 100;
    struct Watcher{
        bool isPay;
        bool isCollected;
    }




    struct Event{
        string title;
        address creator;
        uint domainId;
        uint256 createFee;  
        uint256 joinFee;   
        mapping(address=>Watcher) watchers;
        uint256 count;
        uint256 open_time;
        uint256 finish_time;
        uint256 enableDistribute;
        uint256 price;
        uint256 status;  // 0 normal,  1 cancel
    }

    mapping(bytes32 => Event) public events;



    event CreateEvent(address indexed creator, bytes32 indexed eventId, uint256 indexed createFree, uint statTime, uint256 time, string title);

    event JoinEvent(address indexed watcher, bytes32 indexed eventId);

    event CollectReward(address indexed watcher, bytes32 indexed eventId, uint256 indexed reward);

    event Refunds(address indexed watcher, bytes32 indexed eventId, uint256 indexed refund);

    event ShowStatus(bytes32 indexed id, bool indexed isOk);

    event ShowCancled(bytes32 indexed id);

    event TransferErc20(address indexed from, address indexed to, uint value);


    constructor() public{
        usdtAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        feeAddress = 0x3DD0678EE04C45CDD76A9e540cAaA1b272906971;
        freeperAddress = 0x6C89BE4B5F0B995c062E5A49C5e396BE90616050;
        poolAddress = 0x9978eBE94fB770a1D82Cb5413C15eB5bd99Cb3A8;
    }



    function createEvent(string memory title, uint256 createFee,uint256 startTime, uint256 time, uint256 price) public {
        require(IFreeper(freeperAddress).isVerifiedUser(msg.sender),"not verified account");
        require(IFreeper(freeperAddress).getPublishDomainId(msg.sender)!=0,"not mint nft, please create nft");
        require(time > 0 && time <=180,"invlid time set");
        require(bytes(title).length < 100,"title is too long");
        require(createFee >= 100 ether, "createFee need over 100 ether");
        require(startTime >= block.timestamp,"start time is error");
        
        bytes32 id = keccak256(abi.encodePacked(msg.sender,"1",bytes(title),block.timestamp));
        
        IERC20(usdtAddress).transferFrom(msg.sender, address(this), createFee);
        uint cfee = createFee.mul(createFeeRate).div(1000);

        IERC20(usdtAddress).transfer(feeAddress,cfee);
        IERC20(usdtAddress).transfer(poolAddress,createFee.sub(cfee));

        events[id].createFee = createFee.sub(cfee);
        events[id].creator = msg.sender;
        events[id].domainId = IFreeper(freeperAddress).getPublishDomainId(msg.sender);
        events[id].open_time = startTime;
        events[id].finish_time = startTime.add(time * 1 minutes);
        events[id].price = price;

        emit CreateEvent(msg.sender, id, createFee,startTime, time*1 minutes,title);

    }

    function stopEvent(bytes32 id) public {
        require(events[id].creator != address(0),"event is not exists");
        require(events[id].open_time >= block.timestamp + 1800,"can't cancel order");
        require(events[id].status == 0,"event has been canceled");
        events[id].status = 1;
        emit ShowCancled(id);

    }

    function joinEvent(bytes32 id) public {
        require(events[id].status == 0 , "event has been canceled");
        require(events[id].finish_time!=0 && events[id].finish_time > block.timestamp,"event is finished");
        require(events[id].watchers[msg.sender].isPay == false,"you have paid for this event");

        IERC20(usdtAddress).transferFrom(msg.sender, address(this), events[id].price);
        IERC20(usdtAddress).transfer(poolAddress, events[id].price); // store in freeper contract

        events[id].watchers[msg.sender].isPay = true;
        events[id].count = events[id].count.add(1);
        
        emit JoinEvent(msg.sender, id);
    }

}