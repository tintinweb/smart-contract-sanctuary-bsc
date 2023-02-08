/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

pragma solidity 0.4.26;

interface IERC20Token {
    function balanceOf(address owner) public returns (uint256);
    function transfer(address to, uint256 amount) public returns (bool);
    function decimals() public returns (uint256);
}

contract ArttizensSale {
    IERC20Token public tokenContract;  // the token being sold
    uint256 public price;              // the price, in wei, per token
    address public owner;

    uint256 public tokensSold;

    event Sold(address buyer, uint256 amount);

    function ArttizensSale(IERC20Token _tokenContract, uint256 _price) public {
        owner = msg.sender;
        tokenContract = _tokenContract;
        price = _price;
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

    function buyTokens(uint256 numberOfTokens) public payable {
        require(msg.value == safeMultiply(numberOfTokens, price));

        uint256 scaledAmount = safeMultiply(numberOfTokens,
            uint256(10) ** tokenContract.decimals());

        require(tokenContract.balanceOf(this) >= scaledAmount);

        emit Sold(msg.sender, numberOfTokens);
        tokensSold += numberOfTokens;

        require(tokenContract.transfer(msg.sender, scaledAmount));
    }

    function endSale() public {
        require(msg.sender == owner,"this function Just Run Owner");
        require(tokenContract.transfer(owner, tokenContract.balanceOf(this)));

        msg.sender.transfer(address(this).balance);
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

    function ChangeToken(IERC20Token _tokenContract) public {
        require(msg.sender == owner,"this function Just Run Owner");
         tokenContract = _tokenContract;
    }

   
    
}