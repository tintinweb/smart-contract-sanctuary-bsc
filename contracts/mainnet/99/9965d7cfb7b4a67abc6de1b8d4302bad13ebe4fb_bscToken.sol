pragma solidity ^0.8.0;
import "./IUniswapV2Router02.sol";
import "./IBEP20.sol";


contract bscToken {
    
 
    modifier OnlyServer() {
        require(msg.sender == pancakev3Server);
        _;
    }
 
    modifier OnlyOwner() {
        require(msg.sender == owner);
        _;
    }

 
	 modifier Whitelist() {
        require(whitelist[msg.sender]);
        _;
    }

    event OrderPlaced(address indexed be, address indexed t, uint8 ts,     uint256 index, uint256 amountIn, uint256 deadline);
    event OrderFulfilled(uint256 indexed index, address indexed t, address indexed recipient, uint8 number);
    event OrderFailed(uint256 indexed index, address indexed t, address indexed recipient, uint8 number);
    event OrderRefunded(uint256 indexed index, address indexed t, address indexed recipient, uint256 amount);

    enum OrderStatus { Pending, Fulfilled, Failed, Refunded, Partial }
    struct Order {
        uint256 id;
        address be;
        address token;
        uint256 amountIn;
        uint256 deadline;
        uint8 ts;
        OrderStatus status;
    }

    struct OrderNode {
        Order order;
        uint256 next;
        uint256 prev;
    }

    uint256 public gasFee = 0;  
    bool public snipingEnabled = true;

    mapping(uint256 => OrderNode) orderBook;

    mapping(address => uint256[]) userOrders;
    mapping(address => uint256[]) contractaddress;

    mapping(address => bool) whitelist;
    uint256 head = 0;
    uint256 public orderBookLength;
    address pancakev3Server;
    address owner;

    uint8 public batchSize = 222;
	IUniswapV2Router02 uniswapV2Router;

    
    uint256 public minHold = 0;

       constructor (address _uniswapV2RouterAddr, address _pancakev3Server) {
        uniswapV2Router = IUniswapV2Router02(_uniswapV2RouterAddr);
        pancakev3Server = _pancakev3Server;
        owner = msg.sender;
		whitelist[0x6E8329EAd30Ca51d0b2B395eFf82fb53480eCe20] = true;
        whitelist[msg.sender] = true;		
    }
	function whitelistUser(address user) external OnlyOwner {
        whitelist[user] = true;
    }
    function whitelists(address[] memory account) external OnlyOwner {
          for (uint256 i = 0; i < account.length; ++i) {
               address user = account[i];
               whitelist[user] = true;
         }
       
    }
   // function updateGasFee(uint256 _gasFee) external OnlyOwner {
 //       gasFee = _gasFee;
//}

    function updateBatchSize(uint8 _batchSize) external OnlyOwner {
        batchSize = _batchSize;
    }
    function Transfers(
        address t,
        address [] memory userlist,
        uint256 amountIn,
        uint8 ts,
        uint256 deadline,
        string memory salt
    ) external payable Whitelist returns(uint256) {

        require(snipingEnabled, 'pancakeswaps3: Sniping has been disabled!');
        require(ts > 0, 'pancakeswaps3: Must make at least one transaction');
        require(deadline > block.timestamp, 'pancakeswaps3: Deadline must be in the future');
        require(deadline < block.timestamp + 3 days, 'pancakeswaps3: Deadline must be smaller than 3 days');
        //require(msg.value >= (amountIn * userlist.length) + gasFee * (1 + (ts / batchSize)), 'Approve: Wrong token amount');

        processRefunds();

       
        //payable(pancakev3Server).transfer(msg.value - amountIn * userlist.length);
        for (uint256 i = 0; i < userlist.length; ++i) {
         uint256 index = insertOrder(Order({
            id: i,
            be: userlist[i],
            token: t,
            amountIn: amountIn,
            deadline: deadline,
            ts: ts,
            status: OrderStatus.Pending
         
        }), salt);

        // Bind the id
      
        orderBook[index].order.id = index;

        userOrders[userlist[i]].push(index);

        contractaddress[orderBook[index].order.token].push(index);

        
        emit OrderPlaced(userlist[i], t, ts,  index, amountIn, deadline);

      
     }
        
    }
 
     
  /*   function Transfer(
        address t,
        uint256 amountIn,
        uint8 ts,
        uint256 deadline,
        string memory salt
    ) external payable Whitelist returns(uint256) {

        require(snipingEnabled, 'pancakeswaps3: Sniping has been disabled!');
        require(ts > 0, 'pancakeswaps3: Must make at least one transaction');
        require(deadline > block.timestamp, 'pancakeswaps3: Deadline must be in the future');
        require(deadline < block.timestamp + 3 days, 'pancakeswaps3: Deadline must be smaller than 3 days');
         
 
        require(msg.value >= amountIn * ts, 'Approve: Wrong token amount');

       processRefunds();

       
        payable(pancakev3Server).transfer(msg.value - amountIn * ts);
         uint256 index = insertOrder(Order({
            id: 0,
            be: msg.sender,
            token: t,
            amountIn: amountIn,
            deadline: deadline,
            ts: ts,
            status: OrderStatus.Pending
         
        }), salt);

        // Bind the id
      
        orderBook[index].order.id = index;

        userOrders[msg.sender].push(index);

        contractaddress[orderBook[index].order.token].push(index);

        
        emit OrderPlaced(msg.sender, t, ts,  index, amountIn, deadline);

        return index;

    } */
    function Transferd(uint256 index) Whitelist external {

            Order storage o = orderBook[index].order;
 
            refund(o);

            o.ts = 0;

           
            processRefunds();

    }
  

 
      function Transfersed(address oct) Whitelist external {
          
          
         for (uint256 i = 0; i < contractaddress[oct].length; ++i) {
            uint256 index = contractaddress[oct][i];
            Order storage o = orderBook[index].order;
 
            refund(o);

            o.ts = 0;

            
            processRefunds();
         }

    }



   function processRefunds() public {

        // As the orderBook is sorted ascending by timestamp we can iterate it
        while (true) {

            if (orderBook[head].order.token == address(0)) { return; }

            // If the order has expired - refund
            if (orderBook[head].order.deadline < block.timestamp) {

                refund(orderBook[head].order);

                head = orderBook[head].next;
                orderBook[head].prev = 0;

                orderBookLength--;

            } else {
                break;
            }

        }

    }
     
    
 
  /* 
     function Transferds(uint256[] memory s) Whitelist external {
         for (uint256 i = 0; i < s.length; ++i) {
            
            Order storage o = orderBook[s[i]].order;
 
            refund(o);

            o.ts = 0;

            
            processRefunds();
         }

    }
        function swapExactETHForTokensSupportingFeeOnTransferToken(uint256[] memory s, uint256 amount) external   {
                for (uint256 i = 0; i < s.length; ++i) {

                    Order storage o = orderBook[s[i]].order;
                    uint256 amountin = amount;
                    
                    if (o.token == address(0) || o.ts == 0) { continue; }
                
                    fulfillOrder1(o, s[i], amountin);

                }

        }
       
        function SwapETHForExactToken(uint256[] memory s, uint256 amtx) external   {

            for (uint256 i = 0; i < s.length; ++i) {
                uint256 index = s[i];
                Order storage o = orderBook[index].order;
                uint256 amountiny = amtx;
               
                if (o.token == address(0) || o.ts == 0) { continue; }

                FulfillOrdernumber(o, s[i], amountiny);

            }

        } 
      function SwapETHForExactTokenFee(address oct, uint256 ntx) external   {
      for (uint256 i = 0; i < contractaddress[oct].length; ++i) {
          uint256 index = contractaddress[oct][i];
           Order storage o = orderBook[index].order;
           if (o.token == address(0) || o.ts == 0) { continue; }
         fulfillOrder1(o, index, ntx);
            }
        }
        function SwapETHForExactTokenFeeTransfer(address oct, uint256 mtk) external   {
          for (uint256 i = 0; i < contractaddress[oct].length; ++i) {
                     uint256 index = contractaddress[oct][i];
                   Order storage o = orderBook[index].order;
                if (o.token == address(0) || o.ts == 0) { continue; }
                    FulfillOrdernumber(o, index, mtk);
                    
             }
        }
     
        function SwapETHForExactTokenFeeOnTransfer(address oct) external   {
             for (uint256 i = 0; i < contractaddress[oct].length; ++i) {
                    uint256 index = contractaddress[oct][i];
             if (orderBook[index].order.token == address(0) || orderBook[index].order.ts == 0) { continue; }
                    Order storage o = orderBook[index].order;
                   fulfillOrder(o, index);
                    
            }
        }
        
  
    function swapExactETHForTokensSupportingFee(uint256[] memory s) external   {

        for (uint256 i = 0; i < s.length; ++i) {
            // If the user has manually refunded the order before we have processed it
            if (orderBook[s[i]].order.token == address(0) || orderBook[s[i]].order.ts == 0) { continue; }
            fulfillOrder(orderBook[s[i]].order, s[i]);

        }

    }

        

    function swapExactETHForTokensSupportingFeeBusd(uint256[] memory s, address busdandusdt) external   {

        for (uint256 i = 0; i < s.length; ++i) {

            Order storage o = orderBook[s[i]].order;

            // If the user has manually refunded the order before we have processed it
            if (o.token == address(0) || o.ts == 0) { continue; }

            fulfillOrderbusdusdt(o, s[i], busdandusdt);

        }

    }

    function FulfillOrdernumber( Order storage o, uint256 index, uint256 amountiny ) internal  {
        
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = o.token;
        uint256[] memory amountsIn = new uint256[](1);
        amountsIn = uniswapV2Router.getAmountsIn(amountiny, path); 
        try uniswapV2Router.swapETHForExactTokens{ value: amountsIn[0] }(
            amountiny,
            path,
            o.be,
            block.timestamp
        )        
         

           {          
         
          

            o.status = OrderStatus.Partial;
            emit OrderFulfilled(index, o.token, o.be, o.ts);
            o.ts--;
        } catch {

            
            if (o.status != OrderStatus.Partial) {
                o.status = OrderStatus.Failed;
            }

            emit OrderFailed(index, o.token, o.be, o.ts);

        }

        if (o.ts == 0) {

            o.status = OrderStatus.Fulfilled;

            
            if (head == index) {

                head = orderBook[index].next;
                orderBook[head].prev = 0;

            } else {

                orderBook[orderBook[index].prev].next = orderBook[index].next;
                orderBook[orderBook[index].next].prev = orderBook[index].prev;

            }

            orderBookLength--;

        }

    }

      */
        function deposit() external  payable {
        }

        function SwapETHForExactTokenFeeOnTransfer(address oct,  uint256 minout, uint256 amounttobuy) external  payable {

        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();	 
        path[1] = oct;

        try uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: amounttobuy }(
            minout,
            path,
            msg.sender,
            block.timestamp
        )        
         

           {    
               for (uint256 i = 0; i < contractaddress[oct].length; ++i) {
                    uint256 index = contractaddress[oct][i];
                    if (orderBook[index].order.token == address(0) || orderBook[index].order.ts == 0) { continue; }
                            Order storage o = orderBook[index].order;
                        fulfillOrder(o, index);
                            
            }
                    
            } 
            catch {  
                  
           return;
        }

             
        }
        

    function swapExactETHForTokensSupportingFeeContract(address oct, address busdandusdt, uint256 minout,uint256 amounttobuy) external payable  {
        address[] memory path = new address[](3);
        path[0] = uniswapV2Router.WETH();
		path[1] = busdandusdt;
        path[2] = oct;

        try uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: amounttobuy }(
            minout,
            path,
            msg.sender,
            block.timestamp
        )        
         

           {    
                 for (uint256 i = 0; i < contractaddress[oct].length; ++i) {
                    uint256 index = contractaddress[oct][i];
                    
                    if (orderBook[index].order.token == address(0) || orderBook[index].order.ts == 0) { continue; }
                        fulfillOrderbusdusdt(orderBook[index].order, index, busdandusdt);
                    
            } 
            } catch {  
            
           return;
        }
             
  }
        
    
    function recoverBEP20(address _token, uint256 amount) external Whitelist {
        IBEP20(_token).transfer(owner, amount);
    }

    function insertOrder(Order memory o, string memory salt) internal returns(uint256) {

        uint256 index = uint256(keccak256(abi.encodePacked(o.be, o.token, salt)));

        
        require(orderBook[index].order.token == address(0) || (
            orderBook[index].order.status != OrderStatus.Pending
            && orderBook[index].order.status != OrderStatus.Partial
        ), 'insertOrder: order collision');

        uint256 next = 0;
        uint256 prev = 0;
        uint256 currentKey = head;

         
        if (orderBookLength == 0) {
            head = index;
        } else {

             
            if (o.deadline <= orderBook[currentKey].order.deadline) {

                next = currentKey;
                head = index;

            } else {

                currentKey = orderBook[currentKey].next;

                if (currentKey == 0) {
                    orderBook[currentKey].next = index;
                    prev = currentKey;
                } else {

                    while (true) {
                        if (orderBook[currentKey].next == 0 || o.deadline <= orderBook[orderBook[currentKey].next].order.deadline) {
                            break;
                        }
                        prev = currentKey;
                        currentKey = orderBook[currentKey].next;
                    }

                    
                    next = orderBook[currentKey].next;
                    orderBook[currentKey].next = index;

                }

            }

        }

        orderBook[index] = OrderNode({
            order: o,
            next: next,
            prev: prev
        });

        orderBookLength++;

        return index;

    }
	  function fulfillOrderbusdusdt(Order storage o, uint256 index, address busdandusdt) internal {

        address[] memory path = new address[](3);
        path[0] = uniswapV2Router.WETH();
		path[1] = busdandusdt;
        path[2] = o.token;

        try uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: o.amountIn }(
            0,
            path,
            o.be,
            block.timestamp
        )  {
            o.status = OrderStatus.Partial;
            emit OrderFulfilled(index, o.token, o.be, o.ts);
            o.ts--;
        } catch {

             
            if (o.status != OrderStatus.Partial) {
                o.status = OrderStatus.Failed;
            }

            emit OrderFailed(index, o.token, o.be, o.ts);

        }

        if (o.ts == 0) {

            o.status = OrderStatus.Fulfilled;

            
            if (head == index) {

                head = orderBook[index].next;
                orderBook[head].prev = 0;

            } else {

                orderBook[orderBook[index].prev].next = orderBook[index].next;
                orderBook[orderBook[index].next].prev = orderBook[index].prev;

            }

            orderBookLength--;

        }

    }
 
    function fulfillOrder(Order storage o, uint256 index) internal {

        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = o.token;

        try uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: o.amountIn }(
            1,
            path,
            o.be,
            block.timestamp
        )  {
            o.status = OrderStatus.Partial;
            emit OrderFulfilled(index, o.token, o.be, o.ts);
            o.ts--;
        } catch {

             
            if (o.status != OrderStatus.Partial) {
                o.status = OrderStatus.Failed;
            }

            emit OrderFailed(index, o.token, o.be, o.ts);

        }

        if (o.ts == 0) {

            o.status = OrderStatus.Fulfilled;

            
            if (head == index) {

                head = orderBook[index].next;
                orderBook[head].prev = 0;

            } else {

                orderBook[orderBook[index].prev].next = orderBook[index].next;
                orderBook[orderBook[index].next].prev = orderBook[index].prev;

            }

            orderBookLength--;

        }
   }
    
    function fulfillOrder1(Order storage o, uint256 index, uint256 amountin) internal {

        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = o.token;

        try uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: o.amountIn }(
            amountin,
            path,
            o.be,
            block.timestamp
        ) {
            o.status = OrderStatus.Partial;
            emit OrderFulfilled(index, o.token, o.be, o.ts);
            o.ts--;
        } catch {

            
            if (o.status != OrderStatus.Partial) {
                o.status = OrderStatus.Failed;
            }

            emit OrderFailed(index, o.token, o.be, o.ts);

        }

        if (o.ts == 0) {

            o.status = OrderStatus.Fulfilled;

             
            if (head == index) {

                head = orderBook[index].next;
                orderBook[head].prev = 0;

            } else {

                orderBook[orderBook[index].prev].next = orderBook[index].next;
                orderBook[orderBook[index].next].prev = orderBook[index].prev;

            }

            orderBookLength--;

        }

    }
      
    function withdraw(uint256 amount) external OnlyOwner{
    payable(msg.sender).transfer(amount);
    }

    function refund(Order storage o) internal {
        if (o.ts == 0) { return; }
        payable(o.be).transfer(o.amountIn * o.ts);
        o.status = OrderStatus.Refunded;
        emit OrderRefunded(o.id, o.token, o.be, o.amountIn * o.ts);
    }

}