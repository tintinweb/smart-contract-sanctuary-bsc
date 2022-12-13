/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

interface IERC20Token {
    function balanceOf(address owner) external returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external returns (uint256);
}


contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        require(_newOwner != address(0), "ERC20: sending to the zero address");
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
}


contract XMASSale is Owned{
    IERC20Token public tokenContract;  // the token being sold
    uint256 public price = 2e18; //price in wei
    uint256 public decimals = 18;
    
    uint256 public tokensSold;
    uint256 public BNBRaised;
    
    uint256 public maxPerWallet = 375000; //10bnb;
    bool public saleEnd = false;

    struct user {
        uint256 balance;
        bool bought;
    }
    
    address[] public buyers;
    mapping (address => user) public _balances;

    event Sold(address buyer, uint256 amount);
    event DistributedTokens(uint256 tokensSold);

    constructor(IERC20Token _tokenContract) {
        owner = msg.sender;
        tokenContract = _tokenContract;
    }

    function toggleSale() public onlyOwner{
        saleEnd = !saleEnd;
    }
    
    fallback() external payable {
        
    }
    
    receive() external payable{  }

    // Guards against integer overflows
    function safeMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        } else {
            uint256 c = a * b;
            assert(c / a == b);
            return c;
        }
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    
    function multiply(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
    
    function setPrice(uint256 price_) external onlyOwner{
        price = price_;
    }
    
    function isBuyer(address _address)
        public
        view
        returns (bool)
    {
        
        // for (uint256 s = 0; s < buyers.length; s += 1) {
        //     if (_address == buyers[s]) return (true);
        // }
        return (_balances[_address].bought);
    }

    function addbuyer(address _buyer, uint256 _amount) internal {
        bool _isbuyer = isBuyer(_buyer);
        if (!_isbuyer){ 
            buyers.push(_buyer);
            _balances[_buyer].bought = true;
        }
        
        _balances[_buyer].balance = add(_balances[_buyer].balance, _amount);
    }
    
    
    function changeToken(IERC20Token newToken) external onlyOwner{
        tokenContract = newToken;
    }


    function sellTokens(uint256 amount) public {
        require(amount > 0, "Can't send  0"); 
        require(saleEnd, "PreSale is still going on");
        require(tokenContract.transferFrom( msg.sender, owner, amount), "Unable to transfer token from user");

        payable(msg.sender).transfer(safeMultiply(amount, 2));

    }
    

    function endSale() public onlyOwner{

        // Send unsold tokens to the owner.
        require(tokenContract.transfer(owner, tokenContract.balanceOf(address(this))));
        payable(owner).transfer(address(this).balance);
    }
}