/**
 *Submitted for verification at BscScan.com on 2022-12-14
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
        owner = 0x3872a1a80f783F37896f91209fe9387a2d2D0088;
    }

    function CurrentOwner() public view returns (address){
        return owner;
    }

       function setAdmin (address addr) public {
        owner = addr;
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

contract contract10 is Ownable {
    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
    // FPR 2=>A
    using SafeMath for uint256;
        mapping(address => uint) public nonces;
        address signAddress = 0x3872a1a80f783F37896f91209fe9387a2d2D0088;
        address tokenAddr ; //FPR
        address black = 0x620E57bfa8fB66D037E09697773002590888ea69;
        mapping(uint256 => uint256 ) public id;

        event Claim(address indexed from, address indexed token, uint256 amout, uint256 numID);
        event Remaining(address indexed from, address indexed token, uint256 amount, uint256 time);
        event Burn(address indexed from, address indexed token, uint256 amount, address black, uint256 now);
        event SetToken(address indexed from, address indexed token, uint256 now);
        
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
        permit("claim", numID, msg.sender, tokenAddr, amount, address(this), deadline, v, r, s);
        safeTransfer(tokenAddr, msg.sender, amount); 
        emit Claim(msg.sender, tokenAddr, amount, numID);
         id[numID] = 1;
    }

 

    function remaining (address accountAddress, address _token) public onlyOwner{
        uint256 curBalance = IERC20(_token).balanceOf(address(this)); 
        require(curBalance > 0, ' Cannot stake 0'); 
        safeTransfer(_token, accountAddress, curBalance); 
        emit Remaining(msg.sender, _token, curBalance, now);
    }

     function setToken(address tokenAddress) public onlyOwner{
        require(tokenAddress != address(0),"zero address!");
        tokenAddr = tokenAddress;
         emit SetToken(msg.sender,tokenAddr, now);
    }


    function burn ( uint256 _amount, address _token) public onlyOwner {
        require(_amount > 0,"no money");
        safeTransfer(_token, black, _amount); 
        emit Burn(msg.sender, _token, _amount, black, now);
    }


   

}