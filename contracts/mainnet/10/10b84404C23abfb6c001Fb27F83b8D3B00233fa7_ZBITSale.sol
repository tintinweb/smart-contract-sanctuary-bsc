/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-28
*/

//ZBIT Sale Contract 
//zbit.finance
//ZBIT Company
pragma solidity 0.4.26;

interface IERC20Token {
    function balanceOf(address owner) public returns (uint256);
    function transfer(address to, uint256 amount) public returns (bool);
    function decimals() public returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract ZBITSale {
    IERC20Token public tokenContract;  // the token being sold
    uint256 public price;              // the price, in wei, per token
    //1 bnb = 34000000000000 wei
    //1 wei = 0.000000000000000001 bnb
    //initial Price : 0.000034 bnb per ZBIT
    //initial Price : 
    address public owner;

    mapping(address => uint256) public TokensSupport;

    uint256 public tokensSold;

    event Sold(address buyer, uint256 amount);

    constructor(IERC20Token _tokenContract,uint256 _price) {
        owner = msg.sender;
        price = _price;
        tokenContract = _tokenContract;
    }

    

    function safeMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        } else {
            uint256 c = a * b;
            assert(c / a == b);
            return c;
        }
    }

    function buyZBIT(uint256 numberOfTokens) public payable {
        require(msg.value == safeMultiply(numberOfTokens, price));

        uint256 scaledAmount = safeMultiply(numberOfTokens,
            uint256(10) ** tokenContract.decimals());

        require(tokenContract.balanceOf(this) >= scaledAmount);
        require(tokenContract.transfer(msg.sender, scaledAmount));
        emit Sold(msg.sender, numberOfTokens);
        tokensSold += numberOfTokens;
    }

    function buyZBITByToken(address tokenAddress,uint256 numberOfTokens) public  {
        uint256 priceForSale = numberOfTokens * TokensSupport[tokenAddress];
        IERC20Token tokenSale = IERC20Token(tokenAddress);
        
        uint256 scaledAmount = safeMultiply(numberOfTokens,
            uint256(10) ** tokenContract.decimals());
        require(tokenContract.balanceOf(this) >= scaledAmount);
        
        require(tokenSale.transferFrom(msg.sender,address(this), priceForSale));
        require(tokenContract.transfer(msg.sender, scaledAmount));
        emit Sold(msg.sender, numberOfTokens);
        tokensSold += numberOfTokens;
    }

    function Withdraw() public {
        require(msg.sender == owner,"this function Just Run Owner");
        msg.sender.transfer(address(this).balance);
    }

    function endsale() public{
        require(msg.sender == owner,"this function Just Run Owner");
        require(tokenContract.transfer(owner, tokenContract.balanceOf(this)));
    }

     function WithdrawToken(IERC20Token _token) public {
        require(msg.sender == owner,"this function Just Run Owner");
        _token.transfer(owner,_token.balanceOf(address(this)));
    }

    function sendToWalletOwner() public {
        require(msg.sender == owner,"this function Just Run Owner");
        msg.sender.transfer(address(this).balance);
    }


    function ChangeOwner(address newOwner) public {
        require(msg.sender == owner,"this function Just Run Owner");
        owner = newOwner;
    }

    function ChangePrice(uint256 _price) public {
        require(msg.sender == owner,"this function Just Run Owner");
         price = _price;
    }

    function ChangePriceOfToken(address token,uint256 _price) public {
        require(msg.sender == owner,"this function Just Run Owner");
        TokensSupport[token] = price;
    }

    function ChangeToken(IERC20Token _tokenContract) public {
        require(msg.sender == owner,"this function Just Run Owner");
         tokenContract = _tokenContract;
    }

   function addToken(address token,uint256 price) public {
        require (msg.sender == owner,"this function Just Run Owner");
        TokensSupport[token] = price;
    }
    
}