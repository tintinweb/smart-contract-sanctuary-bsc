/**
 *Submitted for verification at BscScan.com on 2022-06-23
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        assert(a == b * c + a % b); 

        return c;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.7;


contract IntegrityPreSale{

    using SafeMath for uint256;
    IBEP20 public token;

    uint256 public rate = 500000000000;
    address public perSaleOwner;

    mapping(address => bool) public whitelistedAddresses;
    
    constructor(address payable _tokenAddress, address _owner) {
        token = IBEP20(_tokenAddress);
        perSaleOwner = _owner; 
        whitelistedAddresses[0xB2A338a5a9C4B5b0cFd01cf8a9Ad07ef98c08Eb3] = true;
        whitelistedAddresses[0xf6c9a507A8Cc44B70aB0c16564ede3D724393774] = true;
        whitelistedAddresses[0xD13A62d3bd7E52E0a10A072503D969Ef292B78f4] = true;
        whitelistedAddresses[0x9F772d0c5cb0223cb87A299947E1D1FC2eF9de17] = true;
    }

    modifier onlyOwner() {
        require(msg.sender == perSaleOwner, "ONLY_OWNER_CAN_ACCESS_THIS_FUNCTION");
        _;
    }

    modifier isWhitelisted(address _address) {
        require(whitelistedAddresses[_address], "You need to be whitelisted");
        _;
    }   

    function endPreSale() public onlyOwner() {
        uint256 contractTokenBalance = token.balanceOf(address(this));
        token.transfer(msg.sender, contractTokenBalance);
    }

    function buyToken() public payable isWhitelisted(msg.sender){

        uint256 bnbAmountToBuy = msg.value;
        require(bnbAmountToBuy >= 200000000000000000, "MINIMUM BUY : 0.2 BNB");
        require(bnbAmountToBuy <= 2000000000000000000, "MAXIMUM BUY : 2 BNB");

        uint256 tokenAmount = bnbAmountToBuy.mul(rate).div(10**9);

        require(token.balanceOf(address(this)) >= tokenAmount, "INSUFFICIENT_BALANCE_IN_CONTRACT");

        payable(perSaleOwner).transfer(bnbAmountToBuy);

        (bool sent) = token.transferFrom(address(this), msg.sender, tokenAmount);
        require(sent, "FAILED_TO_TRANSFER_TOKENS_TO_BUYER");
        
    }

}