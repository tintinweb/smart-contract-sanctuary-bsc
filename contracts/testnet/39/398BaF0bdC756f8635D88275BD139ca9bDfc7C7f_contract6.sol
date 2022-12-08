/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-29
*/

pragma solidity ^0.5.17;

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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Ownable {
    address private owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public {
        owner = 0x11216C7cfad0b03e501039dc4755E06021c8E851;
    }

    function CurrentOwner() public view returns (address){
        return owner;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


interface IERC20 {
    function balanceOf(address _owner) external view returns (uint256);
}

contract contract6 is Ownable {
    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
    //claim LP
    using SafeMath for uint256;
        mapping(address => uint) public nonces;
        address signAddress = 0x11216C7cfad0b03e501039dc4755E06021c8E851;
        address tokenAddr = 0x46FdeF9029Da5896451B6149d3951A32FEac1734; //GOD
        uint256 public rate = 100;
        uint256 public currencyNum = 1100;
        uint256 public precise = 100000000;
        mapping(uint256 => uint256 ) public id;

        event Claim(address indexed from, address indexed token, uint256 amout, uint256 numID);
        event SetToken(address indexed from, address indexed token, uint256 now);
        event SetRate(address indexed from, uint256 rate, uint256 now);
        event SetCurrencyNum(address indexed from, uint256 currencyNum, uint256 now);
        
  function permit(string memory funType, uint256 numID, address spender, address token, uint256 amount, address _target, uint256 deadline, uint8 v, bytes32 r, bytes32 s) private {
        require(block.timestamp <= deadline, "EXPIRED");
        uint256 tempNonce = nonces[spender]; 
        nonces[spender] = nonces[spender].add(1); 
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(spender, _target, funType, numID, token, amount, deadline, tempNonce))));
        address recoveredAddress = ecrecover(message, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == signAddress, 'INVALID_SIGNATURE');
    }
   
    
    function claim( uint256 numID, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(id[numID] == 0,"id has been generated");
        uint256 curBalance = IERC20(tokenAddr).balanceOf(address(this));
        require(amount.div(precise) < curBalance.mul(rate).div(100).div(precise) || amount.div(precise) < currencyNum,"Insufficient balance");
        permit("claim", numID, msg.sender, tokenAddr, amount, address(this), deadline, v, r, s);

        safeTransfer(tokenAddr, msg.sender, amount); 
        emit Claim(msg.sender, tokenAddr, amount, numID);
         id[numID] = 1;
    }
    
 

     function setToken(address tokenAddress) public onlyOwner{
        require(tokenAddress != address(0),"zero address!");
        tokenAddr = tokenAddress;
         emit SetToken(msg.sender,tokenAddr, now);
    }

    function setRate(uint256 num) public onlyOwner{
        require(num > 0,"not zero!");
        rate = num;
        emit SetRate(msg.sender,rate, now);
    }

     function setCurrencyNum(uint256 num) public onlyOwner{
        require(num > 0,"not zero");
        currencyNum = num;
        emit SetCurrencyNum(msg.sender,currencyNum, now);
    }


   

}