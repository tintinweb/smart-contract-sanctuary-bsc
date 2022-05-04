// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import './TokenManager.sol';
pragma experimental ABIEncoderV2;

contract DexMinimal{

    address public admin;
    address public managerAddress;
    uint nextId;
    mapping(address=>mapping(string=>uint)) public balancelist;
    enum Category{
        BUY,SELL
    }

    struct Order{
        uint id;
        address creator;
        Category category;
        string ticker;
        uint256 amount;
        uint256 filled;
        uint price;
        uint date;
    }


    mapping(string=>mapping(uint=>Order[])) public orderBook;




    constructor()  {
        admin=msg.sender;
    }
    function setTokenManager(address _managerAddress) external onlyAdmin() {
        managerAddress=_managerAddress;
    }


    function createOrder(string memory ticker,uint256 amount,uint price,Category category) external  TokenCheck(ticker) 
    {

        if(category==Category.BUY)
        {   
            uint256 pri = price/1e18; 
            deposit(amount*pri,string('DAI'));
            require(balancelist[msg.sender][string('DAI')]>= amount*pri,"Not enough Dai balance");
        }else if(category==Category.SELL)
        {
            deposit(amount,ticker);
            require(balancelist[msg.sender][ticker]>= amount,"Not enough Token balance");
        }

        Order[] storage orders=orderBook[ticker][uint(category)];

        orders.push(
        Order
         (
         nextId,
         msg.sender,
         category,
         ticker,
         amount,
         0,
         price,
         block.timestamp
        )
        );

        uint i=orders.length-1;

        while(i>0){
            if(category==Category.BUY && orders[i-1].price>orders[i].price){
                break;
            }else if(category==Category.SELL && orders[i-1].price<orders[i].price){
                break;
            }

        Order memory temp=orders[i];
        orders[i]=orders[i-1];
        orders[i-1]=temp;
        i--;
        }
        nextId++;   

    }



    function deposit(uint256 amount,string memory ticker) internal TokenCheck(ticker)  
    {
        TokenManager manager=TokenManager(managerAddress);
        IERC20(manager.getTokenAddress(ticker)).transferFrom(
            msg.sender,
            address(this),
            amount
        );
        balancelist[msg.sender][ticker]+=amount;
    }

     function withdraw(uint256 amount,string memory ticker) internal TokenCheck(ticker)  balanceCheck(amount,ticker)
    {
    TokenManager manager=TokenManager(managerAddress);
    IERC20(manager.getTokenAddress(ticker)).transfer(msg.sender,amount);
    }


    modifier balanceCheck(uint256 amount,string memory ticker) 
    {
        require(balancelist[msg.sender][ticker]>=amount,"not enough balance");
        _;
    }

    modifier TokenCheck(string memory ticker) 
    {
        TokenManager manager=TokenManager(managerAddress);
        require(manager.getTokenAddress(ticker)!=address(0),"Token not available for swap");
        _;
    }

    modifier onlyAdmin()
    {
    require(msg.sender==admin,"Unauthorized");
    _;
    }


    function buy(uint _order_id,string memory ticker) external TokenCheck(ticker)  {
        Order storage order=orderBook[ticker][uint(Category.SELL)][ _order_id];
        uint256 amount=order.amount;
        uint256 price=order.price/1e18;
        require(amount<=balancelist[order.creator][ticker],"currency BALANCE IS LOW ");
        TokenManager manager=TokenManager(managerAddress);
        IERC20(manager.getTokenAddress(string('DAI'))).transferFrom(msg.sender,order.creator,amount*price);
        IERC20(manager.getTokenAddress(ticker)).transfer(msg.sender,order.amount);
        balancelist[order.creator][ticker]-=amount;
        
    }




    function sell(uint _order_id,string memory ticker) external TokenCheck(ticker)  {
        Order storage order=orderBook[ticker][uint(Category.BUY)][ _order_id];
        uint256 amount=order.amount;
        uint256 price=order.price/1e18;
        TokenManager manager=TokenManager(managerAddress);
        IERC20(manager.getTokenAddress(string('DAI'))).transfer(msg.sender,amount*price);
        IERC20(manager.getTokenAddress(ticker)).transferFrom(msg.sender,order.creator,order.amount);
        balancelist[order.creator][string('DAI')]-=amount*price;
        int256 index=indexOf(orderBook[ticker][uint(Category.BUY)],_order_id);
        if(index!=-1){
        orderedArray(uint(index),0,ticker);
        }
       

    }

    function indexOf(Order[] memory arr, uint256 search_id) pure private returns (int256) {
  for (uint256 i = 0; i < arr.length; i++) {
    if (arr[i].id == search_id) {
        int256 res=int(i);
      return res;
    }
  }
  return -1; // not found
}


    function orderedArray(uint index,uint cat,string memory ticker) internal{
        if(cat==0){
            Order[] storage orders=orderBook[ticker][uint(Category.BUY)];
            for(uint i = index; i < orders.length-1; i++){
      orders[i] = orders[i+1];      
    }
    orders.pop();
        }else{
            Order[] storage orders=orderBook[ticker][uint(Category.SELL)];
             for(uint i = index; i < orders.length-1; i++){
      orders[i] = orders[i+1];      
    }
    orders.pop();
        }
    
  }


   


function getOrderBook(string memory ticker,Category category) external view returns(Order[] memory) {

    return orderBook[ticker][uint(category)];
    
}





}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract TokenManager{
struct Token{
    string Ticker;
    address TokenAddress;
}
address public admin;
mapping(string=>Token) public tokens;
string[] public tokenList;

constructor()  {
    admin=msg.sender;

}

function getTokenAddress(string memory ticker) public view returns(address ){ 
    return tokens[ticker].TokenAddress;   
}

function getTokenList() public view returns(string[] memory){ 
    return tokenList;   
}

modifier onlyAdmin(){
    require(msg.sender==admin,"Unauthorized");
    _;
}

function addToken(string memory tiker,address tokenaddress)  public onlyAdmin() {
    tokens[tiker]=Token(tiker,tokenaddress);
    tokenList.push(tiker);
}

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}