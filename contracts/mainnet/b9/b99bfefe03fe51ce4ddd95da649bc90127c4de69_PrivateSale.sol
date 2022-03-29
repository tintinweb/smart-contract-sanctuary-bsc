/**
 *Submitted for verification at BscScan.com on 2022-03-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}




library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

}


contract Ownable   {
    address public _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**

     * @dev Initializes the contract setting the deployer as the initial owner.

     */

    constructor()  {
        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);
    }

    /**

     * @dev Returns the address of the current owner.

     */

    function owner() public view returns (address) {
        return _owner;
    }

    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");

        _;
    }

    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     * Can only be called by the current owner.

     */

    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;
    }
}

contract PrivateSale is Ownable {
    
    
    using SafeMath for uint256;
     mapping(address => bool) public whitelisted;
     bool public whitelist = false;

    
   
    IERC20 public BusdAddress;

    
    
    
    constructor(IERC20  _BusdAddress)  
    {
       
        BusdAddress = _BusdAddress;
        
    }

// THIS FUNCTION WILL WHITELIST ADDRESS

     function whitelistAddress(address[] memory _recipients) public onlyOwner returns (bool) {
        require(_recipients.length <= 100); //maximum receievers can be 500
        for (uint i = 0; i < _recipients.length; i++) {
            whitelisted[_recipients[i]] = true;
        }
        return true;
    }


      /* This Function will blacklist Addresses for presale */
    function blacklistAddress(address[] memory _recipients) public onlyOwner returns (bool) {
        require(_recipients.length <= 100); //maximum receievers can be 500
        for (uint i = 0; i < _recipients.length; i++) {
            whitelisted[_recipients[i]] = false;
        }
        return true;
    }

//........................................Contribute With BUSD...................

         function Contribute(uint256 amount) public 
    {
        
        BusdAddress.transferFrom(msg.sender,address(this),  amount);
         address userAdd = msg.sender;

        if(whitelist){
            require(whitelisted[userAdd],"User is not Whitelisted");
        }
        
    }
    //     function calculateBUSDToken(uint256 amount) public view returns(uint256)
    // {
    //    return (amount.div(BUSDFee)).div(1E18);
    // }
         function withdrawBUSD(uint256 amount) public onlyOwner 
    {
        BusdAddress.transfer(msg.sender,  amount);
    }


  /* This Function will be used to turn on or off whitelisting process */
    function turnWhitelist() public onlyOwner returns (bool success)  {
        if (whitelist) {
            whitelist = false;
        } else {
            whitelist = true;
        }
        return true;
        
    }

}