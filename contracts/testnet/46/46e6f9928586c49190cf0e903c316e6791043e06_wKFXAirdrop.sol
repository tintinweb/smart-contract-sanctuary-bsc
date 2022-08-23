/**
 *Submitted for verification at BscScan.com on 2022-08-23
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-23
*/

//  AMA COIN AIRDROP FOR WHITELIST USER

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

   

    constructor()  {
        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);
    }



    function owner() public view returns (address) {
        return _owner;
    }



    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");

        _;
    }

    /**

     * @dev Transfers ownership of the contract to a new account (newOwner).

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

contract wKFXAirdrop is Ownable {
    
    
    using SafeMath for uint256;

    mapping(address => bool) public processedAirdrops;
    mapping(address => bool) public whitelisted;
       bool public whitelist = false;
    
    // TetherToken token;
    
    IERC20 public tokenAddress;
 
   
     event AirdropProcessed(
    address recipient,
    uint amount,
    uint date
  );
    
    
    constructor(IERC20 _token)  
    {
        tokenAddress = _token;
       
        
    }


 /* This Function will whitelist Addresses for presale */
    function whitelistAddress(address[] memory _recipients) public onlyOwner returns (bool) {
        require(_recipients.length <= 100); //maximum receievers can be 500
        for (uint i = 0; i < _recipients.length; i++) {
            whitelisted[_recipients[i]] = true;
        }
        return true;
    }
    
    

//////////////////////////////////////////////////////////////////////////////////////////


          //........................................CLAIM Airdrop...................

        function airdrop() public {
            address recipient;
            uint amount;
            require(processedAirdrops[recipient] == false, 'airdrop already processed');
             processedAirdrops[recipient] = true;
             tokenAddress.transfer(recipient,2000000000000);
              emit AirdropProcessed(
      recipient,
      amount,
      block.timestamp
    );
            
             address userAdd = msg.sender;

               
        if(whitelist){
            require(whitelisted[userAdd],"User is not Whitelisted");
        }

        }

// check contract balance
     function CheckContractBalance() public view  returns(uint256)
    {
        return  address(this).balance;
    }
    
    
     function withdrawToken(uint256 amount) public onlyOwner 
    {
        require(amount >= 0 , "not have Balance");
        tokenAddress.transfer(msg.sender,  amount);
    }

         function withdrawaBNB(uint256 amount) public onlyOwner 
    {
        payable(msg.sender).transfer(amount);
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