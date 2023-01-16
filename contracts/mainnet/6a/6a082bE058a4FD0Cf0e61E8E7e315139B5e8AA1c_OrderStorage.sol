// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./otcdelegation.sol";
import "./otcRecord.sol";

contract OrderStorage is Ownable {
    using SafeMath for uint256;

    DelegationOrder private _delegationOrder;
    RecordStorage private _recordStorage;
    MerchantInterface private _merchantStorage;

    address public usdtAddress;
    address public otcAddress;

    struct OrderInfo {//订单
        uint orderNo; //订单号
        uint delegationNo; //委托单号 

        address userAddr; //用户
        address merchantAddr; //商家

        uint coinCount; //数量
        uint price; //单价
        uint orderAmount; //总金额
        uint order_type; //1买单,2卖单
        uint status; //0 已转币 1 已打款 2 待打款 3 申诉中 4 已完成  
        bool occupied; //是否占用委托单剩余数量
        uint appeal_type; //0未申诉 1用户申诉,2商家申诉
        
        // uint user_confirm_status; //'客户是否确认支付'
        // uint seller_confirm_status; //商家是否确认支付

        // uint user_confirm_time; //客户确认时间
        // uint seller_confirm_time; //商家确认时间

        // uint appeal_status; //是否申诉
        // uint appeal_type; //1卖家申诉,2买家申诉
        // uint appeal_result_status;//1卖家胜,2买家胜
        // string appeal_result_version;//申诉结果原因
        // uint appeal_time; //申诉时间
        // uint appeal_token_money; //商家申诉质押数量
        // uint appeal_result_time; //申诉结果时间
        // uint appeal_token_money_status; //0没有提现1已提现

        uint pay_type; //支付类型
        string terms; //交易条款       

        uint create_time;
        uint update_time;
    }
    
    event OrderUpdateStatus(uint256 _orderNo, uint256 _orderStatus);

    mapping(uint256 => OrderInfo) private orders; //orderNo ==> OrderInfo
    mapping(uint256 => uint256) private orderIndex;
    OrderInfo[] private orderList;

    uint public apealPledgeAmount; //申诉质押数量

    event OrderAdd(
        uint orderNo,
        uint delegationNo, //质押单号
        address userAddr,
        address buyerAddr, //买家
        address sellerAddr, //卖家
        uint coinCount, //数量
        uint orderAmount, //总金额
        uint payType, //付款方式
        uint orderType //1买单,2卖单
    );  
    
    constructor() {
        usdtAddress = address(0x55d398326f99059fF775485246999027B3197955);
        otcAddress = address(0x3F497Bfdc78686b55d4e58A897464c98691c5881);
        apealPledgeAmount = 10000 * 10**18;
    }    

    address _recordAddr;
    address _delegationAddr;
    address _merchantStorageAddr;

    function authFromContract(
        address __recordAddr,
        address __delegationAddr,
        address __merchantAddr
    ) external onlyOwner {
        _recordAddr = __recordAddr; 
        _delegationAddr = __delegationAddr;
        _merchantStorageAddr = __merchantAddr;

        _recordStorage = RecordStorage(_recordAddr);    
        _delegationOrder = DelegationOrder(_delegationAddr);
        _merchantStorage = MerchantInterface(__merchantAddr);
    }

    function setApealPledgeAmount(uint amount) external onlyOwner{
        apealPledgeAmount = amount;
    }       

    //用户买单
    function addBuyOrder(
        uint _orderNo, //订单号
        uint256 _delegationNo, //委托单号
        uint256 _coinCount, //数量
        uint256 _orderAmount, //总金额
        uint256 _payType //支付方式
    ) external payable {
        require(_delegationAddr != address(0), "delegation address not set");
        require(_recordAddr != address(0), "record address not set");

        _payFee("addBuyOrder");
        DelegationOrder.DelegationInfo memory delegation = _delegationOrder.getDelegationInfo(_delegationNo);
        require(delegation.delegationNo != uint256(0), "DelegationOrder not exist");

        require(delegation.userAddr != msg.sender, "rest not exist");
        require(delegation.itype == 2, "sell DelegationOrder not exist");
        require(_coinCount > 0 && _orderAmount > 0, "coin count error");
        require(delegation.status == 1, "DelegationOrder status error");

        require(_coinCount <= delegation.remainderCount, "insufficient quantity remaining");

        uint _amount = _coinCount.mul(delegation.price).div(10**18);
        require(
            _amount >= delegation.min_money &&
                _amount <= delegation.max_money,
            "amount error"
        );
        
        _delegationOrder.updateRemainCount(_delegationNo, _coinCount, 0); //委托单减少剩余数量      
        _delegationOrder.IncreaseUndoneOrderCount(_delegationNo); //委托单未完成数量 + 1

        _insert(
            _orderNo,
            _delegationNo,
            _coinCount,
            _orderAmount,
            _payType,
            1,//1买单,2卖单
            delegation.userAddr,
            2,
            false
        );
        emit OrderAdd(
            _orderNo,
            _delegationNo,
            msg.sender,
            msg.sender,
            delegation.userAddr,
            _coinCount,
            _orderAmount,
            _payType,
            1      
        ); 
    }

    //用户卖单 合约增加记录 用于转币
    function addSellOrder(
        uint _orderNo, //订单号
        uint256 _delegationNo, //委托单号
        uint256 _coinCount, //数量
        uint256 _orderAmount, //总金额
        uint256 _payType //支付方式
    ) external payable {
        require(_delegationAddr != address(0), "delegation address not set");
        require(_recordAddr != address(0), "record address not set");

        _payFee("addSellOrder");
        DelegationOrder.DelegationInfo memory delegation = _delegationOrder.getDelegationInfo(_delegationNo);
        require(delegation.delegationNo != uint256(0), "DelegationOrder not exist");

        require(delegation.userAddr != msg.sender, "rest not exist");
        require(delegation.itype == 1, "buy DelegationOrder not exist");
        require(_coinCount > 0 && _orderAmount > 0, "coin count error");
        require(delegation.status == 1, "DelegationOrder status error");

        require(_coinCount <= delegation.remainderCount, "insufficient quantity remaining");

        //
        uint _amount = _coinCount.mul(delegation.price).div(10**18);
        require(
            _amount >= delegation.min_money &&
                _amount <= delegation.max_money,
            "amount error"
        );

        _delegationOrder.updateRemainCount(_delegationNo, _coinCount, 0); //委托单减少剩余数量      
        _delegationOrder.IncreaseUndoneOrderCount(_delegationNo); //委托单未完成数量 + 1

        _insert(
            _orderNo,
            _delegationNo,
            _coinCount,
            _orderAmount,
            _payType,
            2,//1买单,2卖单
            delegation.userAddr,
            0,
            true
        );
        //转账usdt到监管合约
        IERC20(usdtAddress).transferFrom(msg.sender, _recordAddr, _coinCount);
        _recordStorage.addRecord(
            _orderNo,
            _delegationNo, 
            delegation.totalCount,
            delegation.remainderCount,
            msg.sender, 
            delegation.userAddr,
            _coinCount,
            2
        );
        emit OrderAdd(
            _orderNo,
            _delegationNo,
            msg.sender,
            delegation.userAddr,
            msg.sender,
            _coinCount,
            _orderAmount,
            _payType,
            2      
        );        
    }

    //用户取消买单
    function cancelBuyOrder(
        uint _orderNo, //订单号
        uint256 _delegationNo //委托单号
    ) external payable onlyUserOrMerchant(_orderNo){
        _payFee("cancelBuyOrder");
        require(_orderNo != uint256(0), "orderNo null");
        OrderInfo memory _order = orders[_orderNo];
        require(_order.orderNo != 0, "order does not exist");         
        require(_order.order_type == 1, "only buy order");

        if(orders[_orderNo].merchantAddr == msg.sender){ //商户只能取消待打款 并且30分钟之后的买单
            require(_order.status == 2, "seller only cancel order status in 2");  //需要处于待打款状态 
            require( block.timestamp - _order.create_time > 30*60, "seller only cancel must be after 30 minutes");  //需要30分钟之后
        }else{ //用户可以取消待打款和已打款的买单
            require(_order.status == 1 || _order.status == 2, "buyer only cancel order status in 1 or 2");  //需要处于待打款和已打款状态
        }      
        
        DelegationOrder.DelegationInfo memory info = _delegationOrder.getDelegationInfo(_delegationNo);
        require(info.delegationNo != uint256(0), "delegation order not exist");   

        _delegationOrder.updateRemainCount(_delegationNo, _order.coinCount, 1); //委托单增加剩余数量 
        _delegationOrder.DecreaseUndoneOrderCount(_delegationNo); //委托单未完成数量 - 1   

        _order.status = 4;
        orders[_orderNo] = _order;
        orderList[orderIndex[_orderNo]] = _order;        
    }

    //用户取消卖单
    function cancelSellOrder(
        uint _orderNo, //订单号
        uint256 _delegationNo //委托单号
    ) external payable onlyUserOrMerchant(_orderNo){
        _payFee("cancelSellOrder");
        require(_orderNo != uint256(0), "orderNo null");
        OrderInfo memory _order = orders[_orderNo];
        require(_order.orderNo != 0, "order does not exist");         
        require(_order.order_type == 2, "only sell order");        
        require(_order.status == 0, "Invalid order status");  //需要处于已转币
        
        if(orders[_orderNo].userAddr == msg.sender){ //用户只能取消30分钟之后的卖单
            require( block.timestamp - _order.create_time > 30*60, "seller only cancel must be after 30 minutes");  //需要30分钟之后
        }

        DelegationOrder.DelegationInfo memory info = _delegationOrder.getDelegationInfo(_delegationNo);
        require(info.delegationNo != uint256(0), "delegation order not exist");   
        
        _recordStorage.callRecord(//用户取消卖单 把币还给用户
            _order.orderNo,
            _order.delegationNo
        );

        _order.status = 4;
        orders[_orderNo] = _order;
        orderList[orderIndex[_orderNo]] = _order;

        _delegationOrder.updateRemainCount(_delegationNo, _order.coinCount, 1); //委托单增加剩余数量 
        _delegationOrder.DecreaseUndoneOrderCount(_delegationNo); //委托单未完成数量 - 1   

    }

    function _insert(
        uint256 _orderNo,
        uint256 _delegationNo,
        uint256 _coinCount,
        uint256 _orderAmount,
        uint256 _payType,
        uint256 _orderType,
        address _merchantAddr,
        uint256 _status,
        bool _occupied
    ) internal returns (uint256 orderNo) {
        require(orders[_orderNo].orderNo == uint256(0), "order exist");        

        DelegationOrder.DelegationInfo memory info = _delegationOrder.getDelegationInfo(_delegationNo);
        require(info.delegationNo != uint256(0), "order not exist");

        OrderInfo memory order = OrderInfo({
            orderNo: _orderNo,
            delegationNo: _delegationNo,
            userAddr: msg.sender,
            merchantAddr: _merchantAddr,
            coinCount: _coinCount,
            price: info.price,
            orderAmount: _orderAmount,
            order_type: _orderType,
            status: _status,
            occupied: _occupied,
            appeal_type: 0,
            pay_type: _payType,
            terms: info.terms, 
            create_time: block.timestamp,
            update_time: 0
        });

        orders[_orderNo] = order;

        orderList.push(order);
        orderIndex[_orderNo] = orderList.length - 1;

        return _orderNo;
    }

    //0 已转币 1 已打款 2 待打款 3 申诉中 4 已完成
    //用户点击已打款 合约增加记录 用于转币
    function alreadyPay(uint256 _orderNo)
        external
        payable
        onlyUser(_orderNo)
    {
        _payFee("alreadyPay");
        require(_orderNo != uint256(0), "orderNo null");
        OrderInfo memory _order = orders[_orderNo];
        require(_order.orderNo != 0, "order does not exist");  
        require(_order.order_type == 1, "only buy order");
        require(_order.status == 2, "Invalid order status");  //需要处于待打款状态
          
        _order.occupied = true;
        _order.status = 1;
        orders[_orderNo] = _order;
        orderList[orderIndex[_orderNo]] = _order;

        DelegationOrder.DelegationInfo memory info = _delegationOrder.getDelegationInfo(_order.delegationNo);
        require(info.delegationNo != uint256(0), "order not exist");       

        //_delegationOrder.updateRemainCount(info.delegationNo, _order.coinCount, 0);  //委托单减少剩余数量  
        //_delegationOrder.IncreaseUndoneOrderCount(info.delegationNo); //委托单未完成数量 + 1

        _recordStorage.addRecord(
            _orderNo,
            info.delegationNo, 
            info.totalCount,
            info.remainderCount,
            info.userAddr,
            msg.sender,             
            _order.coinCount,
            1
        );

        emit OrderUpdateStatus(_order.orderNo, _order.status);
    }

    //商户点击已打款
    function alreadyMerchantPay(uint256 _orderNo)
        external
        payable
        onlyMerchant(_orderNo)
    {
        _payFee("alreadyMerchantPay");
        require(_orderNo != uint256(0), "orderNo null");
        OrderInfo memory _order = orders[_orderNo];
        require(_order.orderNo != 0, "order does not exist");  
        require(_order.order_type == 2, "only sell order");
        require(_order.status == 0, "Invalid order status"); //需要处于已转币状态

        _order.status = 1;
        orders[_orderNo] = _order;
        orderList[orderIndex[_orderNo]] = _order;
        
        emit OrderUpdateStatus(_order.orderNo, _order.status);
    }    

    //用户发起申诉
    function appealOrder(uint256 _orderNo)
        external
        payable
        onlyUser(_orderNo)
    {
        _payFee("appealOrder");
        require(_orderNo != uint256(0), "orderNo null");
        OrderInfo memory _order = orders[_orderNo];
        require(_order.orderNo != 0, "order does not exist");
        require(_order.status != 4,"order completed"); //不能是已完成
        require(_order.status == 1, "Must be in transferred status");  //需要处于已打款状态

        IERC20(otcAddress).transferFrom(msg.sender, _merchantStorageAddr, apealPledgeAmount);

        _merchantStorage.userAppealPledge(
            _order.orderNo,
            _order.delegationNo,
            _order.userAddr,
            _order.merchantAddr,
            apealPledgeAmount
        );

        _order.status = 3;
        _order.appeal_type = 1;
        orders[_orderNo] = _order;
        orderList[orderIndex[_orderNo]] = _order;
     
        emit OrderUpdateStatus(_order.orderNo, _order.status);
    }

    //商家发起申诉
    function appealMerchantOrder(uint256 _orderNo)
        external
        payable
        onlyMerchant(_orderNo)
    {
        _payFee("appealMerchantOrder");
        require(_orderNo != uint256(0), "orderNo null");
        OrderInfo memory _order = orders[_orderNo];
        require(_order.orderNo != 0, "order does not exist");
        require(_order.status != 4,"order completed"); //不能是已完成
        require(_order.status == 1, "Must be in transferred status");  //需要处于已打款状态

        IERC20(otcAddress).transferFrom(msg.sender, _merchantStorageAddr, apealPledgeAmount);

        _merchantStorage.merchantApealPledge(
            _order.orderNo,
            _order.delegationNo,
            _order.userAddr,
            _order.merchantAddr,
            apealPledgeAmount
        );

        _order.status = 3;
        _order.appeal_type = 2;
        orders[_orderNo] = _order;
        orderList[orderIndex[_orderNo]] = _order;
     
        emit OrderUpdateStatus(_order.orderNo, _order.status);
    }
    
    //用户点击已确认 完成订单
    function confirmOrder(uint256 _orderNo)
        external
        payable
        onlyUser(_orderNo)
    {
        _payFee("confirmOrder");
        require(_orderNo != uint256(0), "orderNo null");
        OrderInfo memory _order = orders[_orderNo];
        require(_order.orderNo != 0, "order does not exist");  

        require(_order.status == 1, "Invalid order status");   //需要是已打款状态

        _order.status = 4;
        orders[_orderNo] = _order;
        orderList[orderIndex[_orderNo]] = _order;
        
        _recordStorage.confirmRecord(
            _order.orderNo,
            _order.delegationNo
        );
        
        DelegationOrder.DelegationInfo memory info = _delegationOrder.getDelegationInfo(_order.delegationNo);
        require(info.delegationNo != uint256(0), "order not exist");        
        _delegationOrder.DecreaseUndoneOrderCount(_order.delegationNo); //委托单未完成数量 - 1

        emit OrderUpdateStatus(_order.orderNo, _order.status);
    }

    //商户点击已确认 完成订单
    function confirmMerchantOrder(uint256 _orderNo)
        external
        payable
        onlyMerchant(_orderNo)
    {
        _payFee("confirmMerchantOrder");
        require(_orderNo != uint256(0), "orderNo null");
        OrderInfo memory _order = orders[_orderNo];
        require(_order.orderNo != 0, "order does not exist");  

        require(_order.status == 1, "Invalid order status");  //需要是已打款状态

        _order.status = 4;
        orders[_orderNo] = _order;
        orderList[orderIndex[_orderNo]] = _order;
        
        _recordStorage.confirmMerchantRecord(
            _order.orderNo,
            _order.delegationNo
        );
        
        DelegationOrder.DelegationInfo memory info = _delegationOrder.getDelegationInfo(_order.delegationNo);
        require(info.delegationNo != uint256(0), "order not exist");        
        _delegationOrder.DecreaseUndoneOrderCount(_order.delegationNo); //委托单未完成数量 - 1

        emit OrderUpdateStatus(_order.orderNo, _order.status);
    }

    //管理员处理申诉结果
    function appealConfirmation(
        uint256 _orderNo,
        uint _delegationNo,
        uint _result //0用户赢 1商户赢
    ) external onlyOwner{
        require(_orderNo != uint256(0), "orderNo null");
        OrderInfo memory _order = orders[_orderNo];
        require(_order.orderNo != 0, "order does not exist");         
        require(_order.delegationNo == _delegationNo , "_delegation order is Mismatch");         
        require(_order.status == 3,"Invalid order status"); //需要是申诉中的
        DelegationOrder.DelegationInfo memory info = _delegationOrder.getDelegationInfo(_delegationNo);
        require(info.delegationNo != uint256(0), "delegation order not exist");        

        //0 已转币 1 已打款 2 待打款 3 申诉中 4 已完成 
        if(_order.order_type == 1){//买单
            if(_result == 0){
                _recordStorage.appealHandle(
                    _orderNo,
                    _delegationNo,
                    _result
                );
            }else{
                _delegationOrder.updateRemainCount(_delegationNo, _order.coinCount, 1); //委托单增加剩余数量    
            }
        }else{
            if(_result == 0){
                _recordStorage.appealHandle(
                    _orderNo,
                    _delegationNo,
                    _result
                );
                _delegationOrder.updateRemainCount(_delegationNo, _order.coinCount, 1); //委托单增加剩余数量       
            }else{
                _recordStorage.appealHandle(
                    _orderNo,
                    _delegationNo,
                    _result
                );                 
            }
        }
        //质押合约处理申诉抵押的OTC
        _merchantStorage.handleAppealPledge(_orderNo, _result, _order.appeal_type);

        _order.status = 4;
        orders[_orderNo] = _order;
        orderList[orderIndex[_orderNo]] = _order;
        
        _delegationOrder.DecreaseUndoneOrderCount(_order.delegationNo); //委托单未完成数量 - 1

        emit OrderUpdateStatus(_order.orderNo, _order.status);        
    }

    function getOrderInfo(uint _orderNo) public view returns(OrderInfo memory){
        return orders[_orderNo];
    }    

    modifier onlyUser(uint256 _orderNo) {
        require(_orderNo != uint256(0), "orderNo null");
        require(
            orders[_orderNo].userAddr == msg.sender,
            "only user"
        );
        _;
    }

    modifier onlyMerchant(uint256 _orderNo) {
        require(_orderNo != uint256(0), "orderNo null");
        require(
            orders[_orderNo].merchantAddr == msg.sender,
            "only merchant"
        );
        _;
    }

    modifier onlyUserOrMerchant(uint256 _orderNo) {
        require(_orderNo != uint256(0), "orderNo null");
        require(
            orders[_orderNo].userAddr == msg.sender || orders[_orderNo].merchantAddr == msg.sender,
            "Only user or merchant"
        );
        _;
    }

    //_payFee("pledge");
    mapping(string => address) public feeAddrSet;
    mapping(string => uint256) public feeAmountSet;
    function setFee(string calldata _method,address _addr,uint256 _amount) external onlyOwner {
        feeAddrSet[_method] = _addr;
        feeAmountSet[_method] = _amount;
    }

    function _payFee(string memory _method) internal {
        uint256 _amt = feeAmountSet[_method];
        address _addr = feeAddrSet[_method];

        if (_amt > 0) {
            require(_addr != address(0), "1");
            require(msg.value >= _amt, "2");
            payable(_addr).transfer(_amt);
        }
    }     
}