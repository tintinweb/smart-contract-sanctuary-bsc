/**
 *Submitted for verification at BscScan.com on 2022-10-04
*/

// SPDX-License-Identifier: MIT

 /*---------------.  .----------------.  .----------------.  .----------------.   .----------------.  .----------------.  .----------------. 
| .--------------. || .--------------. || .--------------. || .--------------. | | .--------------. || .--------------. || .--------------. |
| |   ________   | || |  _________   | || |   ______     | || |  ____  ____  | | | |     _____    | || |     ______   | || |     ____     | |
| |  |  __   _|  | || | |_   ___  |  | || |  |_   __ \   | || | |_  _||_  _| | | | |    |_   _|   | || |   .' ___  |  | || |   .'    `.   | |
| |  |_/  / /    | || |   | |_  \_|  | || |    | |__) |  | || |   \ \  / /   | | | |      | |     | || |  / .'   \_|  | || |  /  .--.  \  | |
| |     .'.' _   | || |   |  _|  _   | || |    |  ___/   | || |    > `' <    | | | |      | |     | || |  | |         | || |  | |    | |  | |
| |   _/ /__/ |  | || |  _| |___/ |  | || |   _| |_      | || |  _/ /'`\ \_  | | | |     _| |_    | || |  \ `.___.'\  | || |  \  `--'  /  | |
| |  |________|  | || | |_________|  | || |  |_____|     | || | |____||____| | | | |    |_____|   | || |   `._____.'  | || |   `.____.'   | |
| |              | || |              | || |              | || |              | | | |              | || |              | || |              | |
| '--------------' || '--------------' || '--------------' || '--------------' | | '--------------' || '--------------' || '--------------' |
 '----------------'  '----------------'  '----------------'  '----------------'   '----------------'  '----------------'  '----------------' */

pragma solidity ^0.8.0;

interface IERC20 {
  
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

pragma solidity ^0.8.4;


contract Ownable {
    address private _owner;

    constructor () {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Function accessible only by the owner !!");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
}

contract ZEPCOIN_ICO is Ownable{

    IERC20 usdt = IERC20(
            address(usdt_address) // usdt Token address here just for testing
        );

    IERC20 Busd = IERC20(
            address(busd_address) // busd Token address here just for testing
        );

    uint256 public totalRaisedAmount = 0;
    address public usdt_address;
    address public busd_address;
    bool public icoStatus;
    address public Admin_Wallet;
    address public TokenContract;
    uint256 private current_Price = 10000;
    
   

constructor (address _tokenContract, address _Admin_Wallet){
    Admin_Wallet = _Admin_Wallet;
    TokenContract = _tokenContract;
}

    function ChangePrice(uint256 NewPrice) external onlyOwner{
       current_Price = NewPrice;
    }

    function ChangeTokenAddress (address newAddres) external onlyOwner{
        TokenContract = newAddres;
    }

    function BuyToken_usdt (uint256 Usdt_Amount) public {
        require(!icoStatus,"zepcoin ico is stopped");
        require(Usdt_Amount>=0,"sorry incorect amount");
        usdt.transferFrom(msg.sender,Admin_Wallet,Usdt_Amount);
        IERC20 ZEPX_TK = IERC20(
            address(TokenContract) // ZEPX Token address here just for testing
        );
        ZEPX_TK.transfer(msg.sender,Usdt_Amount*current_Price);
        totalRaisedAmount = totalRaisedAmount + Usdt_Amount;

    }
    
    function BuyToken_busd (uint256 busd_Amount) public {
        require(!icoStatus,"zepcoin ico is stopped");
        require(busd_Amount>=0,"sorry insufficient balance");
        Busd.transferFrom(msg.sender,Admin_Wallet,busd_Amount);
        IERC20 ZEPX_TK = IERC20(
            address(TokenContract) // ZEPX Token address here just for testing
        );
        ZEPX_TK.transfer(msg.sender,busd_Amount*current_Price);
        totalRaisedAmount = totalRaisedAmount + busd_Amount;

    }

    function StopIco () external onlyOwner {
        icoStatus = false;
    }

    function ActivateIco () external onlyOwner {
        icoStatus = true;
    }

   function withdraw_unsoldZEPX(uint256 ZEPX_Ammount) public onlyOwner{
        IERC20 ZEPX_TK = IERC20(
            address(TokenContract) // ZEPX Token address here just for testing
        );
       ZEPX_TK.transfer(msg.sender,ZEPX_Ammount);
   }

   function change_Admin_Wallet (address _new_Admin) public onlyOwner {
       Admin_Wallet = _new_Admin;
   }

   function change_busd_address (address _new_busd_address) public onlyOwner {
       busd_address = _new_busd_address;
   }

   function change_usdt_address (address _new_usdt_address) public onlyOwner {
       usdt_address = _new_usdt_address;
   }
    
}