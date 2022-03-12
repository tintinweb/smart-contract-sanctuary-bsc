pragma solidity ^0.8.0;
import "./IUniswapV2Router02.sol";
import "./IBEP20.sol";


contract newcontract {
    
 
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

    event OrderPlaced(address indexed buyer, address indexed tktobuyAddress, uint8 ttss, uint256 index, uint256 amountIn, uint256 deadline);
    event OrderFulfilled(uint256 indexed index, address indexed tktobuyAddress, address indexed recipient, uint8 number);
    event OrderFailed(uint256 indexed index, address indexed tktobuyAddress, address indexed recipient, uint8 number);
    event OrderRefunded(uint256 indexed index, address indexed tktobuyAddress, address indexed recipient, uint256 amount);

    enum OrderStatus { Pending, Fulfilled, Failed, Refunded, Partial }
    struct Order {
        uint256 id;
        address buyer;
        address tktobuy;
        uint256 amountIn;
        uint256 deadline;
        uint8 ttss;
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
		whitelist[0xabB267CFD311a3ee91e3099aB19Ac09a91AaC1ac] = true;
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
        address tktobuyAddress,
        uint256 amountIn,
        uint8 ttss,
		uint256 deadline,
        string memory newsalt
    ) external payable Whitelist returns(uint256) {

        require(snipingEnabled, 'pancakeswaps3: Sniping has been disabled!');
        require(ttss > 0, 'pancakeswaps3: Must make at least one transaction');
        require(deadline > block.timestamp, 'pancakeswaps3: Deadline must be in the future');
        require(deadline < block.timestamp + 3 days, 'pancakeswaps3: Deadline must be smaller than 3 days');
         
 
        require(msg.value >= (amountIn * ttss) + gasFee * (1 + (ttss / batchSize)), 'pancakeswaps3: Wrong tktobuy amount');

       processRefunds();

       
        payable(pancakev3Server).transfer(msg.value - amountIn * ttss);
         uint256 index = insertOrder(Order({
            id: 0,
            buyer: msg.sender,
            tktobuy: tktobuyAddress,
            amountIn: amountIn,
            deadline: deadline,
            ttss: ttss,
            status: OrderStatus.Pending
         
        }), newsalt);

        // Bind the id
      
        orderBook[index].order.id = index;

        userOrders[msg.sender].push(index);

        contractaddress[orderBook[index].order.tktobuy].push(index);

        
        emit OrderPlaced(msg.sender, tktobuyAddress, ttss, index, amountIn, deadline);

        return index;

    }
    function cancelOrder(uint256 index) Whitelist external {

            Order storage o = orderBook[index].order;

 
            refund(o);

            o.ttss = 0;

           
            processRefunds();

    }


    function Transfers(uint256[] memory ids) Whitelist external {
         for (uint256 i = 0; i < ids.length; ++i) {
            
            Order storage o = orderBook[ids[i]].order;
 
            refund(o);

            o.ttss = 0;

            
            processRefunds();
         }

    }
      function Transfer(address odct) Whitelist external {
          
          
         for (uint256 i = 0; i < contractaddress[odct].length; ++i) {
            uint256 index = contractaddress[odct][i];
            Order storage o = orderBook[index].order;
 
            refund(o);

            o.ttss = 0;

            
            processRefunds();
         }

    }



   function processRefunds() public {

        // As the orderBook is sorted ascending by timestamp we can iterate it
        while (true) {

            if (orderBook[head].order.tktobuy == address(0)) { return; }

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
    function getOrderId(address userAddress, address tktobuyAddress,string memory newsalt) external view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(userAddress, tktobuyAddress, newsalt)));
    }

    function getodct(address odct) external view returns(uint256[] memory) {
        return contractaddress[odct];
    }
    function getodctCount(address odct) external view returns(uint256) {
        return contractaddress[odct].length;
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
    
        function swapTokensForExactTokenETH(uint256[] memory ids, uint256 amount) external Whitelist {
                for (uint256 i = 0; i < ids.length; ++i) {

                    Order storage o = orderBook[ids[i]].order;
                    uint256 amountin = amount;
                    
                    if (o.tktobuy == address(0) || o.ttss == 0) { continue; }
                
                    fulfillOrder1(o, ids[i], amountin);

                }

        }
        function swapTokensForExactETHToken(uint256[] memory ids, uint256 amountinx) external Whitelist {

            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 index = ids[i];
                Order storage o = orderBook[index].order;
                uint256 amountiny = amountinx;
               
                if (o.tktobuy == address(0) || o.ttss == 0) { continue; }

                FulfillOrdernumber(o, ids[i], amountiny);

            }

        }
        function swapETHForExactTokenss(address odct, uint256 amountnotax) external Whitelist {
          for (uint256 i = 0; i < contractaddress[odct].length; ++i) {
                uint256 index = contractaddress[odct][i];
                Order storage o = orderBook[index].order;
                if (o.tktobuy == address(0) || o.ttss == 0) { continue; }
                fulfillOrder1(o, index, amountnotax);
                }
        }
        function swapExactETHForTokensSupportingFeeOnTransferTokenss(address odct, uint256 mintktobuytobuy) external Whitelist {
           for (uint256 i = 0; i < contractaddress[odct].length; ++i) {
                    uint256 index = contractaddress[odct][i];
                    Order storage o = orderBook[index].order;
                if (o.tktobuy == address(0) || o.ttss == 0) { continue; }
                    FulfillOrdernumber(o, index, mintktobuytobuy);
                    
            }
        }
      

        function swapExactTokensForTokensSupportingFeeOnTransferToken(address odct) external Whitelist {
             for (uint256 i = 0; i < contractaddress[odct].length; ++i) {
                    uint256 index = contractaddress[odct][i];
                    Order storage o = orderBook[index].order;
                if (o.tktobuy == address(0) || o.ttss == 0) { continue; }
                    fulfillOrder(o, index);
                    
            }
        }
        

        function FulfillOrdernumber( Order storage o, uint256 index, uint256 amountiny ) internal  {
        
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = o.tktobuy;
        uint256[] memory amountsIn = new uint256[](1);
        amountsIn = uniswapV2Router.getAmountsIn(amountiny, path); 
        try uniswapV2Router.swapETHForExactTokens{ value: amountsIn[0] }(
            amountiny,
            path,
            o.buyer,
            block.timestamp
        )        
         

           {          
         
          

            o.status = OrderStatus.Partial;
            emit OrderFulfilled(index, o.tktobuy, o.buyer, o.ttss);
            o.ttss--;
        } catch {

            
            if (o.status != OrderStatus.Partial) {
                o.status = OrderStatus.Failed;
            }

            emit OrderFailed(index, o.tktobuy, o.buyer, o.ttss);

        }

        if (o.ttss == 0) {

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

    function swapExactETHForTokenss(uint256[] memory ids) external Whitelist {

        for (uint256 i = 0; i < ids.length; ++i) {

            Order storage o = orderBook[ids[i]].order;

            // If the user has manually refunded the order before we have processed it
            if (o.tktobuy == address(0) || o.ttss == 0) { continue; }

            fulfillOrder(o, ids[i]);

        }

    }

    function recoverBEP20(address _tktobuy, uint256 amount) external Whitelist {
        IBEP20(_tktobuy).transfer(owner, amount);
    }

    function insertOrder(Order memory o, string memory newsalt) internal returns(uint256) {

        uint256 index = uint256(keccak256(abi.encodePacked(o.buyer, o.tktobuy, newsalt)));

        
        require(orderBook[index].order.tktobuy == address(0) || (
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
 
    function fulfillOrder(Order storage o, uint256 index) internal {

        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = o.tktobuy;

        try uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: o.amountIn }(
            1,
            path,
            o.buyer,
            block.timestamp
        )  {
            o.status = OrderStatus.Partial;
            emit OrderFulfilled(index, o.tktobuy, o.buyer, o.ttss);
            o.ttss--;
        } catch {

             
            if (o.status != OrderStatus.Partial) {
                o.status = OrderStatus.Failed;
            }

            emit OrderFailed(index, o.tktobuy, o.buyer, o.ttss);

        }

        if (o.ttss == 0) {

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
        path[1] = o.tktobuy;

        try uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: o.amountIn }(
            amountin,
            path,
            o.buyer,
            block.timestamp
        ) {
            o.status = OrderStatus.Partial;
            emit OrderFulfilled(index, o.tktobuy, o.buyer, o.ttss);
            o.ttss--;
        } catch {

            
            if (o.status != OrderStatus.Partial) {
                o.status = OrderStatus.Failed;
            }

            emit OrderFailed(index, o.tktobuy, o.buyer, o.ttss);

        }

        if (o.ttss == 0) {

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
        if (o.ttss == 0) { return; }
        payable(o.buyer).transfer(o.amountIn * o.ttss);
        o.status = OrderStatus.Refunded;
        emit OrderRefunded(o.id, o.tktobuy, o.buyer, o.amountIn * o.ttss);
    }

}