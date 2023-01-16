// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./otcdelegation.sol";

contract RecordStorage is Ownable {
    using SafeMath for uint256;

    address public usdtAddress;

    struct Record {
        uint orderNo; //订单号 唯一值
        uint delegationNo; //委托单号 
        uint totalCount; //总数量
        uint remainderCount; //剩余数量
        address userAddr; 
        address buyerAddr; //买家
        uint coinCount; //数量
        uint status; //0 未完成  1 完成
        uint orderType; //1买单,2卖单
        uint create_time;
        uint update_time;
    }

    mapping(uint256 => Record) public records;  //orderNo ==> Record
    mapping(uint256 => uint256) public recordIndex;

    Record[] public recordList;
    
    constructor() {
        usdtAddress = address(0x55d398326f99059fF775485246999027B3197955);
    }

    function addRecord(
        uint _orderNo,
        uint _delegationNo, 
        uint _totalCount,
        uint _remainderCount,
        address _userAddr, 
        address _buyerAddr,
        uint _coinCount,
        uint _orderType
    ) public onlyAuthFromOrderAddr {

        require(records[_orderNo].orderNo == uint256(0), "record exist");  

        Record memory _record = Record({
            orderNo: _orderNo,
            delegationNo: _delegationNo,
            totalCount: _totalCount,
            remainderCount: _remainderCount,
            userAddr: _userAddr,
            buyerAddr: _buyerAddr,
            coinCount: _coinCount,
            status: 0,
            orderType: _orderType,
            create_time: block.timestamp,
            update_time: 0
        });

        records[_orderNo] = _record;

        recordList.push(_record);
        recordIndex[_orderNo] = recordList.length - 1;
    }

    //用户确认订单 把币转给商户
    function confirmRecord(
        uint _orderNo,
        uint _delegationNo
    ) public onlyAuthFromOrderAddr{
        Record memory _record = records[_orderNo];
        require(_record.orderNo != 0, "order does not exist");   
        require(_record.delegationNo == _delegationNo, "delegation does not exist");  
        require(_record.status == 0, "order status error");

        IERC20(usdtAddress).transfer(_record.buyerAddr, _record.coinCount); 
        _record.status = 1;
        _record.update_time = block.timestamp;
        
        records[_orderNo] = _record;
        recordList[recordIndex[_orderNo]] = _record;        
    } 

    //用户取消卖单 把币还给用户
    function callRecord(
        uint _orderNo,
        uint _delegationNo
    ) public onlyAuthFromOrderAddr{
        Record memory _record = records[_orderNo];
        require(_record.orderNo != 0, "order does not exist");   
        require(_record.delegationNo == _delegationNo, "delegation does not exist");  
        require(_record.status == 0, "order status error");

        IERC20(usdtAddress).transfer(_record.userAddr, _record.coinCount); 
        _record.status = 1;
        _record.update_time = block.timestamp;
        
        records[_orderNo] = _record;
        recordList[recordIndex[_orderNo]] = _record;        
    }  

    //商户取消卖单 把币还给商户
    function callMerchantRecord(
        address userAddr,
        uint coinCount
    ) public onlyAuthFromDelegationAddr{
        IERC20(usdtAddress).transfer(userAddr, coinCount);        
    }  
    
    //商家确认订单 把币转给用户
    function confirmMerchantRecord(
        uint _orderNo,
        uint _delegationNo
    ) public onlyAuthFromOrderAddr{
        Record memory _record = records[_orderNo];
        require(_record.orderNo != 0, "order does not exist");   
        require(_record.delegationNo == _delegationNo, "delegation does not exist");  
        require(_record.status == 0, "order status error");

        IERC20(usdtAddress).transfer(_record.buyerAddr, _record.coinCount); 
        _record.status = 1;
        _record.update_time = block.timestamp;
        
        records[_orderNo] = _record;
        recordList[recordIndex[_orderNo]] = _record;        
    }

    //处理申诉结果 进行转币
    function appealHandle(
        uint _orderNo,
        uint _delegationNo,
        uint _result  //0用户赢 1商户赢
    ) public onlyAuthFromOrderAddr{
        Record memory _record = records[_orderNo];
        require(_record.orderNo != 0, "order does not exist");       
        require(_record.delegationNo == _delegationNo, "delegation does not exist");  
        
        require(_record.status == 0, "order not in complaint");

        _record.status = 1;
        _record.update_time = block.timestamp;
        
        records[_orderNo] = _record;
        recordList[recordIndex[_orderNo]] = _record;

        //将币转到赢的一方 orderType; //1买单,2卖单
        if (_result == 0){
            if(_record.orderType == 1){ //买单 把币转给买家
                IERC20(usdtAddress).transfer( _record.buyerAddr, _record.coinCount);
            }else if(_record.orderType == 2){ //卖单 把币转给卖家
                IERC20(usdtAddress).transfer( _record.userAddr, _record.coinCount);
            }
        }else if (_result == 1){
            if(_record.orderType == 2){ //卖单 把币转给买家
                IERC20(usdtAddress).transfer( _record.buyerAddr, _record.coinCount);
            }            
        }
    }

    function updateRecordStatus2(
        uint _orderNo,
        uint _delegationNo,
        uint status  //0买家赢 1卖家赢
    ) public onlyOwner{
        Record memory _record = records[_orderNo];
        require(_record.orderNo != 0, "order does not exist");       
        require(_record.delegationNo == _delegationNo, "delegation does not exist");  
        
        require(_record.status == 0, "order not in complaint");

        _record.status = 1;
        _record.update_time = block.timestamp;
        
        records[_orderNo] = _record;
        recordList[recordIndex[_orderNo]] = _record;

        //将币转到赢的一方
        if (status == 0){
            IERC20(usdtAddress).transferFrom(address(this), _record.buyerAddr, _record.coinCount);    
        }else{
            IERC20(usdtAddress).transferFrom(address(this), _record.userAddr, _record.coinCount);    
        }
    }    

    address _orderAddr;
    address _delegationAddr;
    modifier onlyAuthFromOrderAddr() {
        require(_orderAddr == msg.sender, "Invalid contract address");
        _;
    }

    modifier onlyAuthFromDelegationAddr() {
        require(_delegationAddr == msg.sender, "Invalid contract address");
        _;
    }

    function authFromContract(
        address __orderAddr,
        address __delegationAddr
    ) external onlyOwner {
        _orderAddr = __orderAddr;  
        _delegationAddr = __delegationAddr;

    }      
}