/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

pragma solidity ^0.8.6;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);


    event Approval(address indexed owner, address indexed spender, uint256 value);
}//ierc library
library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        
        
        
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        
        
        

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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
//safemath

struct Player{
    uint8 choice;
    uint256 amountDeposited;
}

    //globals & data structs


//

contract SuperBowlPool {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using SafeMath for uint40;

    IERC20 public USDT;

    mapping (address => Player) players;

    address payable public ceoWallet;
    address payable public devWallet;

    uint16 constant public ceoFee = 50;
    uint16 constant public devFee = 50;
    uint256 constant public leftOver = 900;
    uint16 constant percentDivider = 1000;

    uint256 pool1Total;
    uint256 pool2Total;
    uint256 entirePool;
    uint8 winner;
    
    uint40 sbDate = 1644771600;
    uint40 sbDateStart = 1643694722; //1644771600;

    constructor(address payable ceoAddress, address payable devAddress){
        ceoWallet = ceoAddress;
        devWallet = devAddress;

        // USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
        USDT = IERC20(0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47); //Binance testnet BUSD
    }

    //globals

    //functions


    function makeBet(uint8 selection, uint256 amount) external {
        require (selection == 1 || selection == 2);
        // require (amount >= 20);
        require (block.timestamp > sbDateStart);

        Player storage player = players[msg.sender];
        

        if (player.choice != 0){
            require (player.choice == selection );
        }

        uint40 currentTime = uint40 (block.timestamp);

        uint256 cfee  = amount.mul(ceoFee).div(percentDivider);
        uint256 dfee  = amount.mul(devFee).div(percentDivider);
       
        USDT.safeTransferFrom(msg.sender, address(this), amount);
        USDT.safeTransfer(ceoWallet, cfee);
        USDT.safeTransfer(devWallet, dfee);
        
        
        player.choice = selection;
        uint256 realAmount = amount.mul(leftOver).div(percentDivider);
        player.amountDeposited += realAmount;

        if (selection == 1){
            pool1Total += realAmount;
            entirePool += realAmount;
        }
        else {
            pool2Total += realAmount;
            entirePool += realAmount;
        }
        
    }

    function withdraw()external returns (uint256 someName){
        Player storage player = players[msg.sender];
        require (winner == 1 || winner == 2);
        require (player.choice == winner);

        //uint40 currentTime = uint40(block.timestamp);
        //require(currentTime > sbDate);

        uint256 totalWithdrawable = player.amountDeposited;
        require(totalWithdrawable > 0);

         if (player.choice == winner && player.choice == 1){
            
            uint256 percentOfpool = totalWithdrawable.mul(percentDivider).div(pool1Total);
            uint256 poolWinnings = percentOfpool.mul(pool2Total).div(percentDivider);
            uint256 playerPayout = totalWithdrawable + poolWinnings;
            USDT.safeTransfer(msg.sender, playerPayout);
            return playerPayout;
        }
            
        else if (player.choice == winner && player.choice == 2) {

            uint256 percentOfpool = totalWithdrawable.mul(percentDivider).div(pool2Total);
            uint256 poolWinnings = percentOfpool.mul(pool1Total).div(percentDivider);
            uint256 playerPayout = totalWithdrawable + poolWinnings;
            
            USDT.safeTransfer(msg.sender, playerPayout);
            return playerPayout;
        }
    }
    

    function theScore(uint8 result) external {
        require (msg.sender == ceoWallet);
        winner = result;
        }
    
    function getInfo() view external returns
        (uint8 playersChoice, 
        uint256 playersInvestment, 
        uint256 totalEntirePool, 
        uint256 totalPool1,
        uint256 totalPool2
    ) {
        Player storage player = players[msg.sender];
        
        
        return (
            player.choice,
            player.amountDeposited,
            entirePool,
            pool1Total,
            pool2Total
        );
    }

}