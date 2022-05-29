/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

pragma solidity ^0.5.0;


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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

   
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

   
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity ^0.5.5;


library Address {
   
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

   
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

   
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity ^0.5.0;


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

contract multisendnew {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    address public owner;
    
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    
    constructor() public{
        owner = msg.sender;
    }
   
    //getowner
    function getOwner() public view returns (address) {
        return owner;
    }
    
    //get token balance
    function getTokenBalance(IERC20 token) public view returns (uint256) {
        return token.balanceOf(address(this));
    }
    
    //withdraw whole erc20 token balance
    function withdraw(IERC20 token) public onlyOwner{
        token.safeTransfer(msg.sender, token.balanceOf(address(this)));
    }

    //get eth balance
    function getEthBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    //withdraw whole balance
    function withdraweth() public onlyOwner{
        msg.sender.transfer(address(this).balance);
    }
    
    //batch send fixed token amount from sender, require approval of contract as spender
    function multiSendFixedToken(IERC20 token, address[] memory recipients, uint256 amount) public payable {
        
        address from = msg.sender;
        
        require(recipients.length > 0);
        require(amount > 0);
        require(recipients.length * amount <= token.allowance(from, address(this)));
        
        for (uint256 i = 0; i < recipients.length; i++) {
            token.safeTransferFrom(from, recipients[i], amount);
        }
        
    }  
    
    //batch send different token amount from sender, require approval of contract as spender
    function multiSendDiffToken(IERC20 token, address [] memory recipients, uint256[] memory amounts) public  payable{
        
        require(recipients.length > 0);
        require(recipients.length == amounts.length);
        
        address from = msg.sender;
        
        uint256 allowance = token.allowance(from, address(this));
        uint256 currentSum = 0;
        
        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 amount = amounts[i];
            
            require(amount > 0);
            currentSum = currentSum.add(amount);
            require(currentSum <= allowance);
            
            token.safeTransferFrom(from, recipients[i], amount);
        }
        
    }   
     
    
    //batch send fixed token amount from contract
    function multiSendFixedTokenFromContract(IERC20 token, address[] memory recipients, uint256 amount) public onlyOwner {
        require(recipients.length > 0);
        require(amount > 0);
        require(recipients.length * amount <= token.balanceOf(address(this)));
        
        for (uint256 i = 0; i < recipients.length; i++) {
            token.safeTransfer(recipients[i], amount);
        }
    }
    
    //batch send different token amount from contract
    function multiSendDiffTokenFromContract(IERC20 token, address[] memory recipients, uint256[] memory amounts) public onlyOwner {
        
        require(recipients.length > 0);
        require(recipients.length == amounts.length);
        
        uint256 length = recipients.length;
        uint256 currentSum = 0;
        uint256 currentTokenBalance = token.balanceOf(address(this));
        
        for (uint256 i = 0; i < length; i++) {
            uint256 amount = amounts[i];
            require(amount > 0);
            currentSum = currentSum.add(amount);
            require(currentSum <= currentTokenBalance);
            
            token.safeTransfer(recipients[i], amount);
        }
    }
      function disperseEther(address payable[] memory recipients, uint256[] memory values) public payable {
        for (uint256 i = 0; i < recipients.length; i++)
            recipients[i].transfer(values[i]);
       
    }

    function disperseToken(IERC20 token, address[] memory recipients, uint256[] memory values) public payable  {
        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++)
            total += values[i];
        require(token.transfer(address(this), total));
        for (uint256 i = 0; i < recipients.length; i++)
            require(token.transfer(recipients[i], values[i]));
    }

      //batch send fixed eth amount from sender
    function multiSendFixedEth(address payable[] memory recipients, uint256 amount) public payable {
        
        require(recipients.length > 0);
        require(amount > 0);
        require(recipients.length * amount == msg.value);
        
        uint256 length = recipients.length;
        
        for(uint256 i=0;i<length;i++) {
            recipients[i].transfer(amount);
        }
    }   
    
    //batch send different eth amount from sender
    function multiSendDiffEth(address payable[] memory recipients, uint256[] memory amounts) public payable {
        require(recipients.length > 0);
        require(recipients.length == amounts.length);
        
        uint256 length = recipients.length;
        uint256 currentSum = 0;
        
        for (uint256 i = 0; i < length; i++) {
            uint256 amount = amounts[i];
            require(amount > 0);
            currentSum = currentSum.add(amount);
            require(currentSum <= msg.value);
           
            recipients[i].transfer(amount);
        }
        
    }
    
    
    //batch send fixed eth amount from contract
    function multiSendFixedEthFromContract(address payable[] memory recipients, uint256 amount) public onlyOwner {
        
        require(recipients.length > 0);
        require(amount > 0);
        require(recipients.length * amount <= address(this).balance);
        
        uint256 length = recipients.length;
        
        for(uint256 i=0;i<length;i++) {
            recipients[i].transfer(amount);
        }
    }    
    
    //batch send different eth amount from contract
    function multiSendDiffEthFromContract(address payable[] memory recipients, uint256[] memory amounts) public onlyOwner {
        
        require(recipients.length > 0);
        require(recipients.length == amounts.length);
        
        uint256 length = recipients.length;
        uint256 currentSum = 0;
        uint256 currentEthBalance = address(this).balance;
        
        for (uint256 i = 0; i < length; i++) {
            uint256 amount = amounts[i];
            require(amount > 0);
            currentSum = currentSum.add(amount);
            require(currentSum <= currentEthBalance);
           
            recipients[i].transfer(amount);
        }
    }   
    
}