/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function safeTransferFrom(address,address,uint,uint,bytes memory) external;
}
contract Escrow {

    uint256 public orders;    //订单编号
    uint256 public waittime;  //提起申诉到执行仲裁之间的最低保护时间
    mapping (uint256 => HostingInfo)  public hostingInfo;    //订单对应的合同信息
    mapping (address => uint256[])  public partyAorders;      //订单发起者的订单列表，便于查询
    mapping (address => uint256[])  public partyBorders;   //订单接受者的订单列表，便于查询

    struct HostingInfo {
        uint256 id;                   //订单号
        address arbitrationContract;  //出现争议后，申诉的仲裁合约
        address asset;                //担保的资产(不支持扣税的资产）
        uint256 assetClass;           //资产类别,0:ERC20,1:ERC721,2:ERC1155
        uint256 tokenId;              //资产类别,NFT编码
        address[3] participant;       //participant[0]订单发起者，participant[1]订单接受者，participant[2]退款钱包地址
        uint256 amount;               //订单担保的资产数量
        uint256 payed;                //已经支付的资产数量
        uint256 partyAmargin;         //发起方缴纳的保证金数量
        uint256 partyBmargin;         //接受方缴纳的保证金数量
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
    struct ParticipantInfo {
        address partyApurse;       //participant[0]订单发起者
        address partyBpurse;       //participant[1]订单接受者
        address backpurse;         //pparticipant[2]退款钱包地址
    }
    constructor(uint256 _waittime) {
        waittime = _waittime;
    }
    //发布订单
    function release(address _arbitrationContract,address _asset, uint256 _assetClass, uint256 _tokenId,address _sender,uint256 _amount,uint256 _partyAmargin,
                    address _recipient,uint256 _partyBmargin,address _comeback,string memory _contracthash) external returns(uint256) {

        if(_assetClass == 0 && _tokenId == 0) {   //REC20
            uint256 wad = _amount + _partyAmargin;
            TokenLike(_asset).transferFrom(msg.sender,address(this),wad);
        }
        else if(_assetClass == 1 && _amount == 1 && _partyAmargin == 0 && _partyBmargin == 0) {   //REC721
           TokenLike(_asset).transferFrom(msg.sender,address(this),_tokenId);
        }
        else if(_assetClass == 2 && _partyAmargin == 0 && _partyBmargin == 0) {   //REC1155
           TokenLike(_asset).safeTransferFrom(msg.sender,address(this),_tokenId,_amount,"");
        }
        else revert("2");

        orders +=1;
        HostingInfo memory host = hostingInfo[orders];
            host.asset = _asset;
            host.assetClass = _assetClass;
            host.amount = _amount;
            host.tokenId = _tokenId;
            host.participant[0] = _sender;
            host.participant[1] = _recipient;
            host.participant[2] = _comeback;
            host.contracthash = _contracthash;
            host.partyAmargin = _partyAmargin;
            host.partyBmargin = _partyBmargin;
            host.arbitrationContract = _arbitrationContract;
        hostingInfo[orders] = host;
        partyAorders[_sender].push(orders);
        partyBorders[_recipient].push(orders);
        return orders;
    }
    //接受方确认订单
    function confirm(uint256 order,string memory _contracthash) public {
        HostingInfo storage host = hostingInfo[order]; 
        require(host.participant[1] == msg.sender,"1"); //函数调用者地址必须是对应订单的接受方
        require(keccak256(abi.encodePacked(host.contracthash)) == keccak256(abi.encodePacked(_contracthash)),"1"); //双方的链下合同哈希值必须一致
        if(host.assetClass == 0) TokenLike(host.asset).transferFrom(msg.sender,address(this),host.partyBmargin);
        host.isConfirm = true;
    }
    //发送方支付资产给接受方
    function performance(uint256 order,uint256 payAmount) public {
        HostingInfo storage host = hostingInfo[order]; 
        require(host.endmark < 4,"1");  //订单没有被申诉
        require(host.isConfirm == true,"1"); // 接受方已确认
        require(host.participant[0] == msg.sender,"1"); //函数调用者地址必须是对应订单的发起方
        require(payAmount <= host.amount - host.payed && payAmount != 0,"1"); //可以分批支付
        host.payed += payAmount;
        if(host.assetClass == 0) TokenLike(host.asset).transfer(host.participant[1],payAmount);
        if(host.assetClass == 1) TokenLike(host.asset).transferFrom(address(this),host.participant[1],host.tokenId);
        if(host.assetClass == 2) TokenLike(host.asset).safeTransferFrom(address(this),host.participant[1],host.tokenId,payAmount,"");
    }
    //接受方终止合约，退回发送方资金
    function returnfunds(uint256 order,uint256 backAmount) public {
        HostingInfo storage host = hostingInfo[order]; 
        require(host.endmark < 4,"1"); //订单没有被申诉
        require(host.participant[1] == msg.sender,"1"); //函数调用者地址必须是对应订单的接受方
        require(host.isConfirm == true,"1"); // 接受方已确认
        require(backAmount <= host.amount - host.payed && backAmount != 0,"1"); //可以部分退回
        host.amount -= backAmount;
        if(host.assetClass == 0) TokenLike(host.asset).transfer(host.participant[2],backAmount);
        if(host.assetClass == 1) TokenLike(host.asset).transferFrom(address(this),host.participant[2],host.tokenId);
        if(host.assetClass == 2) TokenLike(host.asset).safeTransferFrom(address(this),host.participant[2],host.tokenId,backAmount,""); 
    }
    //接受方未确认的订单，发起方可以撤回资金
    function backcontract(uint256 order) public {
        HostingInfo storage host = hostingInfo[order]; 
        require(host.participant[0] == msg.sender,"1");
        require(host.isConfirm == false,"1");

        if(host.assetClass == 0) {
            uint256 wad = host.amount + host.partyAmargin;
            host.amount = 0;
            host.partyAmargin = 0;
            host.partyBmargin = 0;
            TokenLike(host.asset).transfer(host.participant[2],wad);
        }
        if(host.assetClass == 1 && host.amount == 1) {
            host.amount = 0;
            TokenLike(host.asset).transferFrom(address(this),host.participant[2],host.tokenId);
        }
        if(host.assetClass == 2) {
            uint256 wad = host.amount;
            host.amount = 0;
            TokenLike(host.asset).safeTransferFrom(address(this),host.participant[2],host.tokenId,wad,"");
        }
    }
    //赎回保证金
    function returnMargin(uint256 order) public {
        HostingInfo storage host = hostingInfo[order]; 
        require(host.endmark < 3,"1");  //订单没有被申诉
        if(host.participant[1] == msg.sender && (host.endmark == 0 || host.endmark == 1)) host.endmark +=2;
        if(host.participant[0] == msg.sender && (host.endmark == 0 || host.endmark == 2)) host.endmark +=1;
        if(host.endmark == 3) {  
           //双方都同意后才能赎回，并且同时赎回
           TokenLike(host.asset).transfer(host.participant[2],host.partyAmargin);
           TokenLike(host.asset).transfer(host.participant[1],host.partyBmargin);  
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
        require(senderAmount + recipientAmount == host.amount + host.partyAmargin + host.partyBmargin - host.payed,"1");  //分配的资产必须等于订单剩余总资产
        host.endmark = 5;
        if(host.assetClass == 0) {  
            TokenLike(host.asset).transfer(host.participant[2],senderAmount);
            TokenLike(host.asset).transfer(host.participant[1],recipientAmount);
        }
        if(host.assetClass == 1) {  
            if (senderAmount == 1)TokenLike(host.asset).transferFrom(address(this),host.participant[2],host.tokenId);
            if (recipientAmount == 1)TokenLike(host.asset).transferFrom(address(this),host.participant[1],host.tokenId);
        }
        if(host.assetClass == 2) {  
            TokenLike(host.asset).safeTransferFrom(address(this),host.participant[2],host.tokenId,senderAmount,"");
            TokenLike(host.asset).safeTransferFrom(address(this),host.participant[1],host.tokenId,recipientAmount,"");
        }
    }
    
    //仲裁合约需要获取的信息
    function getHostingInfo(uint256 order) public view returns (address partyA,address partyB,uint256 assetAmount) {
        HostingInfo storage host = hostingInfo[order];
        partyA = host.participant[0];
        partyB = host.participant[1];
        assetAmount = host.amount + host.partyAmargin + host.partyBmargin - host.payed;
    }
    //托管订单列表
    function listOrder(uint256 count) external view returns (HostingInfo[] memory,ParticipantInfo[] memory) {
        uint length = orders;
        if (count !=0 && count < length) length = count;
        HostingInfo[] memory host = new HostingInfo[](length);
        ParticipantInfo[] memory Participants = new ParticipantInfo[](length);
        uint max = orders;
        uint j; 
        for (uint i = max; i >=1; --i) {
            HostingInfo memory One = hostingInfo[i];
            One.id = i;
            Participants[j].partyApurse = One.participant[0];
            Participants[j].partyBpurse = One.participant[1];
            Participants[j].backpurse = One.participant[2];
            host[j] = One;
            j +=1;
            if (i-1 == max-length) break;
        }
        return (host,Participants);
    }
    //作为甲方的订单列表
    function orderFroA(address usr,uint256 count) external view returns (HostingInfo[] memory,ParticipantInfo[] memory) {
        uint length = partyAorders[usr].length;
        if (count !=0 && count < length) length = count;
        HostingInfo[] memory host = new HostingInfo[](length);
        ParticipantInfo[] memory Participants = new ParticipantInfo[](length);
        uint max = partyAorders[usr].length -1;
        uint j; 
        for (uint i = max; i >=0; --i) {
            uint n = partyAorders[usr][i];
            HostingInfo memory One = hostingInfo[n];
            One.id = n;
            Participants[j].partyApurse = One.participant[0];
            Participants[j].partyBpurse = One.participant[1];
            Participants[j].backpurse = One.participant[2];
            host[j] = One;
            j +=1;
            if (i-1 == max-length) break;
        }
        return (host,Participants);
    }
    
    //作为乙方方的订单列表
    function orderFroB(address usr,uint256 count) external view returns (HostingInfo[] memory,ParticipantInfo[] memory) {
       uint length = partyBorders[usr].length;
        if (count !=0 && count < length) length = count;
        HostingInfo[] memory host = new HostingInfo[](length);
        ParticipantInfo[] memory Participants = new ParticipantInfo[](length);
        uint max = partyBorders[usr].length -1;
        uint j; 
        for (uint i = max; i >=0; --i) {
            uint n = partyBorders[usr][i];
            HostingInfo memory One = hostingInfo[n];
            One.id = n;
            Participants[j].partyApurse = One.participant[0];
            Participants[j].partyBpurse = One.participant[1];
            Participants[j].backpurse = One.participant[2];
            host[j] = One;
            j +=1;
            if (i-1 == max-length) break;
        }
        return (host,Participants);
    }
}