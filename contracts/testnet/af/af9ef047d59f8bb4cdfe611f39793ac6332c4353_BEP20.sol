/**
 *Submitted for verification at BscScan.com on 2022-09-11
*/

pragma solidity >=0.8.0;


enum DEAL_TYPE{ BUY, SELL}
struct Deal { 
    uint256 Ticket;
    DEAL_TYPE cmd;
    string currency;
   uint256  price;
   uint qty;
   address owner;
}

struct Position { 
    uint256 qty;
    uint256 avaragePrice;
}

contract  BEP20 {
    string public name; // Holds the name of the token
    string public symbol; // Holds the symbol of the token
    uint8 public decimals; // Holds the decimal places of the token
    uint256 public totalSupply; // Holds the total suppy of the token
    address payable public owner; // Holds the owner of the token

    uint256 public lastTicket;
    /* This creates a mapping with all balances */
    mapping (address => uint256) public balanceOf;
    /* This creates a mapping of accounts with allowances */
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (string => Deal[] ) public orderBook;
    mapping (address => mapping (string => Position)) public positions;

    /* This event is always fired on a successfull call of the
       transfer, transferFrom, mint, and burn methods */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    /* This event is always fired on a successfull call of the approve method */

    event DealNew(Deal _deal1);
    event DealPartialFill(Deal _deal1);
    event DealFullFill(Deal _deal1);


     function placeDeal(address _to, string memory _cur, DEAL_TYPE _cmd, uint256 _price, uint _qty) public returns (bool success) {

        require(_to != address(0), "Receiver address invalid");
        require(_price >= 0, "_price must be greater or 0");
        require(_qty > 0, "_qty must be greater then 0");

        lastTicket = lastTicket + 1;

        transfer(owner, _price*_qty);
//        Deal[] memory deals = orderBook[_cur];
            Deal memory deal = Deal(
                lastTicket,
                _cmd,
                _cur,
                _price,
                 _qty,
                msg.sender
            );

        orderBook[_cur].push(deal);
        emit DealNew(deal);
        matchDeals(deal);

        return true;
    }

    function matchDeals(Deal memory deal) public{
            Deal[] memory deals = orderBook[deal.currency];
            uint j=0;
            uint len;
            
            for (j = 0; j < deals.length; ++j) {  //for loop example
                Deal memory dealIter = deals[j];
                if (dealIter.cmd != deal.cmd && dealIter.Ticket != deal.Ticket)
                {
                    orderBook[deal.currency][j] = orderBook[deal.currency][len - 1];
                    orderBook[deal.currency].pop();
//transferFrom(address _from, address _to, uint256 _value)
                    uint256 position1Profit = updatePosition(dealIter);
                    uint256 position2Profit = updatePosition(deal);
                    uint256 owner1Balance = dealIter.qty*dealIter.price;
                    uint256 owner2Balance = dealIter.qty*deal.price;
                    if (position1Profit != 0){
                        owner1Balance = owner1Balance + position1Profit;
                        owner2Balance = owner2Balance - position1Profit;
                    }
                     if (position2Profit != 0){
                        owner1Balance = owner1Balance - position2Profit;
                        owner2Balance = owner2Balance + position2Profit;
                    }
                    transferFrom(owner, dealIter.owner,owner1Balance);
                    transferFrom(owner, deal.owner,owner2Balance);
                  
                    emit DealFullFill(dealIter);
                    emit DealFullFill(deal);

                }
                len++;         
            }        
    }

    function updatePosition(Deal memory deal) public returns (uint256) {
                    Position memory pos1 = positions[deal.owner][deal.currency];
                    uint256 profit = 0;
                    if (deal.cmd == DEAL_TYPE.BUY)
                    {
                        pos1.avaragePrice = ((pos1.avaragePrice*pos1.qty)+(deal.price*deal.qty)) / (pos1.qty+deal.qty);
                        pos1.qty = pos1.qty + deal.qty;
                    }else{
                        profit = pos1.avaragePrice * deal.qty;
//                        pos1.avaragePrice = ((pos1.avaragePrice*pos1.qty)-(deal.price*deal.qty)) / (pos1.qty-deal.qty);
                        pos1.qty = pos1.qty - deal.qty;
                    }
                    positions[deal.owner][deal.currency] = pos1;        
            return profit;
    }

    constructor() {
        name = "ZZDEC"; // Sets the name of the token, i.e Ether
        symbol = "ZZDEC"; // Sets the symbol of the token, i.e ETH
        decimals = 2; // Sets the number of decimal places
        uint256 _initialSupply = 100000000000000; // Holds an initial supply of coins
        lastTicket = 0;
        /* Sets the owner of the token to whoever deployed it */
        owner = payable(msg.sender);

        balanceOf[owner] = _initialSupply; // Transfers all tokens to owner
        totalSupply = _initialSupply; // Sets the total supply of tokens

        /* Whenever tokens are created, burnt, or transfered,
            the Transfer event is fired */
        emit Transfer(address(0), msg.sender, _initialSupply);
    }
function getOwner() public view returns (address) {
        return owner;
    }

     function transfer(address _to, uint256 _value) public returns (bool success) {
        uint256 senderBalance = balanceOf[msg.sender];
        uint256 receiverBalance = balanceOf[_to];

        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(senderBalance > _value, "Not enough balance");

        balanceOf[msg.sender] = senderBalance - _value;
        balanceOf[_to] = receiverBalance + _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value)
      public returns (bool success) {
        uint256 senderBalance = balanceOf[msg.sender];
        uint256 fromAllowance = allowance[_from][msg.sender];
        uint256 receiverBalance = balanceOf[_to];
        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(senderBalance > _value, "Not enough balance");
        require(fromAllowance >= _value, "Not enough allowance");

        balanceOf[_from] = senderBalance - _value;
        balanceOf[_to] = receiverBalance + _value;
        allowance[_from][msg.sender] = fromAllowance - _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_value > 0, "Value must be greater than 0");

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }


function mint(uint256 _amount) public returns (bool success) {
        require(msg.sender == owner, "Operation unauthorised");

        totalSupply += _amount;
        balanceOf[msg.sender] += _amount;

        emit Transfer(address(0), msg.sender, _amount);
        return true;
    }
    function burn(uint256 _amount) public returns (bool success) {
      require(msg.sender != address(0), "Invalid burn recipient");

      uint256 accountBalance = balanceOf[msg.sender];
      require(accountBalance > _amount, "Burn amount exceeds balance");

      balanceOf[msg.sender] -= _amount;
      totalSupply -= _amount;

      emit Transfer(msg.sender, address(0), _amount);
      return true;
    }
}