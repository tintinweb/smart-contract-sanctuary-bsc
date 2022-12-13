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


contract BUYXMASToken is Owned{
    IERC20Token public tokenContract;  // the token being sold
    
    uint256 public tokensSold;
    uint256 public BNBRaised;
    uint256 public TotalPresaleAmount;
    
    uint256 public maxPerWallet = 100000000000000000000; //100bnb;
    bool public PresaleStarted = false;

    address public sellSmartContract = address(0);

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

    function changeSellSmartContract(address _sellSmartContract) external onlyOwner{
        require(_sellSmartContract != address(0), "Don't set it to Zero");
        sellSmartContract = _sellSmartContract;
    }
    
    fallback() external payable {
        buyTokensWithBNB(msg.sender);
    }
    
    receive() external payable{ buyTokensWithBNB(msg.sender); }

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
    
    function togglePresale() public onlyOwner{
        PresaleStarted = !PresaleStarted;
    }
    
    function changeToken(IERC20Token newToken) external onlyOwner{
        tokenContract = newToken;
    }


    function buyTokensWithBNB(address _receiver) public payable {
        require(PresaleStarted, "Presale not started yet! or Finished");
        uint256 _amount = msg.value;
        require(_amount >= 100000000000000000 && _amount <= 100000000000000000000, "Min or Max value not met");
        require(_receiver != address(0), "Can't send to 0x00 address"); 
        require(_amount > 0, "Can't buy with 0 BNB"); 
        
        uint256 newAmount = add(_balances[msg.sender].balance, _amount);
        require(newAmount <= maxPerWallet, "Error: Max Allowed per wallet limit ");
        
        //send to smart Contract
        uint256 hamount = div(_amount , 2);
        require(payable(sellSmartContract).send(hamount), "Unable to transfer BNB to owner");
        require(payable(owner).send(_amount - hamount), "Unable to transfer BNB to owner");
        BNBRaised += _amount;
        
        addbuyer(msg.sender, _amount);
        require(tokenContract.transfer( msg.sender, _amount), "Unable to transfer token to user");
        emit Sold(msg.sender, _amount);
                
    }
    

    function endSale() public onlyOwner{

        // Send unsold tokens to the owner.
        require(tokenContract.transfer(owner, tokenContract.balanceOf(address(this))));
         // Send stuck bnb to owner
        payable(owner).transfer(address(this).balance);
    }
}