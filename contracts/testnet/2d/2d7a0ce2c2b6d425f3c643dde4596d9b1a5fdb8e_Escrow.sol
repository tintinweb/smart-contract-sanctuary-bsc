/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
}
contract Escrow {

    uint256 public orders;    //订单编号
    uint256 public waittime;  //提起申诉到执行仲裁之间的最低保护时间
    mapping (uint256 => HostingInfo)  public hostingInfo;    //订单对应的合同信息
    mapping (address => uint256[])  public senderOrder;      //订单发起者的订单列表，便于查询
    mapping (address => uint256[])  public recipientOrder;   //订单接受者的订单列表，便于查询

    struct HostingInfo {
        address arbitrationContract;  //出现争议后，申诉的仲裁合约
        address asset;                //担保的资产(不支持扣税的资产）
        address[3] participant;       //participant[0]订单发起者，participant[1]订单接受者，participant[2]退款钱包地址
        uint256 amount;               //订单担保的资产数量
        uint256 payed;                //已经支付的资产数量
        uint256 initiatorMargin;      //发起方缴纳的保证金数量
        uint256 recipientMargin;      //接受方缴纳的保证金数量
        uint256 endmark;              //保证金赎回及申诉状态标识
                                        //0，保证金还未开始赎回
                                        //1，发起方同意赎回保证金
                                        //2，接受方同意赎回保证金
                                        //3，保证金已赎回
                                        //4，进入申述流程
                                        //5，申述被执行
        uint256 starttime;            //申诉启动时间
        string  contracthash;         //链下合同内容的哈希值  
        bool    isConfirm;            //接受方确认合同状态
    }
    constructor(uint256 _waittime) {
        waittime = _waittime;
    }
    //发布订单
    function release(address _arbitrationContract,address _asset,address _sender,uint256 _amount,uint256 _initiatorMargin,address _recipient,uint256 _recipientMargin,address _comeback,string memory _contracthash) external {
        uint256 wad = _amount + _initiatorMargin;
        TokenLike(_asset).transferFrom(msg.sender,address(this),wad);
        orders +=1;
        HostingInfo memory host = hostingInfo[orders];
            host.asset = _asset;
            host.amount = _amount;
            host.participant[0] = _sender;
            host.participant[1] = _recipient;
            host.participant[2] = _comeback;
            host.contracthash = _contracthash;
            host.initiatorMargin = _initiatorMargin;
            host.recipientMargin = _recipientMargin;
            host.arbitrationContract = _arbitrationContract;
        hostingInfo[orders] = host;
        senderOrder[_sender].push(orders);
        recipientOrder[_recipient].push(orders);
    }
    //接受方确认订单
    function confirm(uint256 order,string memory _contracthash) public {
        HostingInfo storage host = hostingInfo[order]; 
        require(host.participant[1] == msg.sender,"1"); //函数调用者地址必须是对应订单的接受方
        require(keccak256(abi.encodePacked(host.contracthash)) == keccak256(abi.encodePacked(_contracthash)),"1"); //双方的链下合同哈希值必须一致
        TokenLike(host.asset).transferFrom(msg.sender,address(this),host.recipientMargin);
        host.isConfirm = true;
    }
    //发送方支付资产给接受方
    function performance(uint256 order,uint256 payAmount) public {
        HostingInfo storage host = hostingInfo[order]; 
        require(host.endmark < 4,"1");  //订单没有被申诉
        require(host.participant[0] == msg.sender,"1"); //函数调用者地址必须是对应订单的发起方
        require(payAmount >= host.amount - host.payed,"1"); //可以分批支付
        host.payed += payAmount;
        TokenLike(host.asset).transfer(host.participant[1],payAmount);
    }
    //接受方终止合约，退回发送方资金
    function returnfunds(uint256 order,uint256 backAmount) public {
        HostingInfo storage host = hostingInfo[order]; 
        require(host.endmark < 4,"1"); //订单没有被申诉
        require(host.participant[1] == msg.sender,"1"); //函数调用者地址必须是对应订单的接受方
        require(backAmount <= host.amount - host.payed,"1"); //可以部分退回
        host.amount -= backAmount;
        TokenLike(host.asset).transfer(host.participant[2],backAmount); 
    }
    //接受方未确认的订单，发起方可以撤回资金
    function backcontract(uint256 order) public {
        HostingInfo storage host = hostingInfo[order]; 
        require(host.participant[0] == msg.sender,"1");
        require(host.isConfirm == false,"1");
        uint256 wad = host.amount + host.initiatorMargin;
        host.amount = 0;
        host.initiatorMargin = 0;
        TokenLike(host.asset).transfer(msg.sender,wad);
    }
    //赎回保证金
    function returnMargin(uint256 order) public {
        HostingInfo storage host = hostingInfo[order]; 
        require(host.endmark < 3,"1");  //订单没有被申诉
        if(host.participant[1] == msg.sender && (host.endmark == 0 || host.endmark == 1)) host.endmark +=2;
        if(host.participant[0] == msg.sender && (host.endmark == 0 || host.endmark == 2)) host.endmark +=1;
        if(host.endmark == 3) {  
           //双方都同意后才能赎回，并且同时赎回
           TokenLike(host.asset).transfer(host.participant[2],host.initiatorMargin);
           TokenLike(host.asset).transfer(host.participant[1],host.recipientMargin);  
        }
    }
    //申述
    function appeal(uint256 order) public {
        HostingInfo storage host = hostingInfo[order]; 
        require(host.participant[0] == msg.sender || host.participant[1] == msg.sender,"1");  //只有当事双方才能发起申述
        require(host.endmark < 3,"1"); // 保证金被赎回后不能再申述
        host.endmark = 4;
        host.starttime = block.timestamp;  //申诉启动时间
    }
    //由仲裁合约分配资产
    function arbitration(uint256 order,uint256 senderAmount,uint256 recipientAmount) public {
        HostingInfo storage host = hostingInfo[order]; 
        require(host.endmark == 4,"1");    //只有启动申述后才有效 
        require(block.timestamp >= host.starttime + waittime,"1");  //只有超过申诉保护时间后才可以执行
        require(host.arbitrationContract == msg.sender,"1");   //只有订单选择的仲裁合约才可以执行
        require(senderAmount + recipientAmount == host.amount + host.initiatorMargin + host.recipientMargin - host.payed,"1");  //分配的资产必须等于订单剩余总资产
        host.endmark = 5;
        TokenLike(host.asset).transfer(host.participant[2],senderAmount);
        TokenLike(host.asset).transfer(host.participant[1],recipientAmount);
    }
    //仲裁合约需要获取的信息
    function getHostingInfo(uint256 order) public view returns (address partyA,address partyB,uint256 assetAmount) {
        HostingInfo storage host = hostingInfo[order];
        partyA = host.participant[0];
        partyB = host.participant[1];
        assetAmount = host.amount + host.initiatorMargin + host.recipientMargin - host.payed;
    }
}