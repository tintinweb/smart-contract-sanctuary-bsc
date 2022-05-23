/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

pragma solidity ^0.4.26;



contract Ownable {
    address public owner;

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

contract ERC20 {
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function transferFrom( address from, address to, uint value) returns (bool ok);
}


contract IDO is Ownable {

    address preSaleWallet = 0x974774635c0569EcACC0bC1A0778884BeE807569;
    address tokenAddress = 0x3999734e51F0A3e176283f7D01e438112393D1F7;

    mapping (address => uint256) preSaleUser;
    uint256 public BNBDecimals = 18;
    uint256 public TokenDecimals = 18;
    uint256 public preSalePrice = 500;


    function preSale() payable returns (bool _success) {
        if(preSaleUser[msg.sender] > 0){
            preSaleWallet.transfer(msg.value);
            preSaleUser[msg.sender] +=(msg.value);
            return true;
        }
        preSaleWallet.transfer(msg.value);
        preSaleUser[msg.sender] = msg.value;
        return true;
    }

    function claims(address to) public {
        uint256 amount = preSaleUser[to];
        require(amount > 0,"balance is zero");
        uint256 tokenAmount = amount * preSalePrice;
        ERC20 token = ERC20(tokenAddress);
        token.transfer(to, tokenAmount);
        preSaleUser[to] = 0;
    }

    function claim(address _token) public onlyOwner {
        if (_token == 0x0) {
            owner.transfer(this.balance);
            return;
        }
        ERC20 erc20token = ERC20(_token);
        uint256 balance = erc20token.balanceOf(this);
        erc20token.transfer(owner, balance);
    }

    function getClaims(address account) public view returns (uint256) {
        uint256 amount = preSaleUser[account];
        uint256 tokenAmount = amount * preSalePrice;
        return tokenAmount;
    }
    
    function getUser(address account) public view returns (uint256) {
        return preSaleUser[account];
    }
    
    function setPreSalePrice(uint256 newPrice) onlyOwner{
        preSalePrice = newPrice;
    }

}