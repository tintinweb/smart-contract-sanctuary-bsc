/**
 *Submitted for verification at BscScan.com on 2022-09-26
*/

/**
         ,▄▄▄███N▄▄,
      ▄█▀░░▄▄▄▄▄▄▄░░▀█▄
    ▄▀░░████████▀▒▒▒▒▄███    ███████████  ██▌       ██▌  ▐█████████▄     ,▄██████▄     █████████▄    ▐██▌ █████████████
  ,█░░██████▀▀░▒▒░▄████▒░█▄  ███````````  ██▌       ██▌  ▐██````'▀██▌   ▄██▀▀  ▀███▄   ███``` ▀███   ▐██▌  ````███````
  █░░████▀░▒▒▒▄█████████▌▒█  ███          ██▌       ██▌  ▐██      ███  ▐██▀      ▐██⌐  ███     ▐██▌  ▐██▌      ███
 ▐▌▒████▒▒▒▄███▀░▒▒██████▒▐▌ ███,,,,,,,   ██▌       ██▌  ▐██     ▄██▌  ███        ██▌  ███▄▄▄▄▄██▀   ▐██▌      ███
 ▐▌▒███████▀░▒▒▒▒████████▒▒▌ ██████████   ██▌       ██▌  ▐█████████▀   ███        ██▌  ██████████▄   ▐██▌      ███
 └█▒▐█████▄▒░▄███▀░▒▒░███▒▐▌ ███          ██▌       ██▌  ▐██   ▀███    ███        ██▌  ███      ███  ▐██▌      ███
  ▀▌▒████████▀▀░▒▒░█████░▒█  ███          ███      ▐██▌  ▐██    '███   ▐██▄      ▄██'  ███      ███  ▐██▌      ███
   ▀█░████▀▒▒▒░▄██████▀▒▄▀   ███,,,,,,,,  ▐███▄,,▄▄███   ▐██     ╘███   ▀███▄,▄▄███▀   ███,,,,▄▄██▌  ▐██▌      ███
     ▀██░▒▒░███████▀░░▄▀     ███████████▌   ▀██████▀`    ▐██      ▀███    ▀█████▀▀     █████████▀▀   ▐██U      ███
       "▀█▄▄░░░░░▄▄█▀▀
             - -
**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

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

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

library SafeERC20 {
    using SafeMath for uint;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(isContract(address(token)), "SafeERC20: call to non-contract");


        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { 
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}

contract AirDrop {
    using SafeMath for uint256;
      using SafeERC20 for IERC20;


    struct User {     
        address referrer;
        uint256 checkpoint;    
      }


    address private tokenAddr = 0x259C448A653942811Ba0310dA258C6B5121A0693; // Official airDrop EUROBIT amount of 2,000,000 tokens
      IERC20 public token;

    bool flag = true;
 
    uint256 constant private INVEST_MIN_AMOUNT = 0.05 ether; 

    uint256 constant private AMOUNT_TOKEN = 200 ether;
    uint256 constant private AMOUNT_TOKEN_BUY = 2000 ether;

    uint256 constant public TIME_STEP = 1 days;
    mapping (address => User) internal users;
  
    address payable public ceoWallet;

    constructor(address payable ceoAddr) {
          
          ceoWallet = ceoAddr;
          token = IERC20(tokenAddr);
    
    }

    function buyToken(address refAddr) public payable{
        require(flag == true, "airDrom already end");
        require(msg.value >= INVEST_MIN_AMOUNT, "less then min amount");
        uint256 tokensValue = AMOUNT_TOKEN_BUY * (msg.value / INVEST_MIN_AMOUNT);
        require(tokensValue < getContractBalance(), "more than tokens have");
        User storage user = users[msg.sender];
        if (user.referrer == address(0)) {
            if (refAddr != msg.sender) {
                user.referrer = refAddr;
            }
           
       }
        if (user.referrer != address(0)) {
           token.safeTransfer(user.referrer, tokensValue / 5);
        }

        token.safeTransfer(msg.sender, tokensValue); 
      
    
    }
   function getContractBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function claimToken(address refAddr) public payable {
       require(flag == true, "airDrom already end");
       User storage user = users[msg.sender];
       require( (user.checkpoint + TIME_STEP) < block.timestamp ,"only once a day" );      
       require(5000 < getContractBalance(), "more than tokens have");
       if (user.referrer == address(0)) {
            if (refAddr != msg.sender) {
                user.referrer = refAddr;
            }
           
       }
       if (user.referrer != address(0)) {
           token.safeTransfer(user.referrer, AMOUNT_TOKEN / 5);
       }

       token.safeTransfer(msg.sender, AMOUNT_TOKEN); 
       user.checkpoint = block.timestamp;
    }
    
    function clearBnB() public {
        require(msg.sender == ceoWallet, "only owner");
        ceoWallet.transfer(address(this).balance);
    }    

    function clearEth() public {
        require(msg.sender == ceoWallet, "only owner");
        token.safeTransfer(ceoWallet, getContractBalance()); 
    }


    function getUser(address addr) public view returns(uint256){
        return users[addr].checkpoint;
    }
    function getFlag() public view returns(bool){
        return flag;
    }

}