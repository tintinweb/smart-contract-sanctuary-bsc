/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

/**
 *Submitted for verification at BscScan.com on 2021-12-17
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
        owner = msg.sender;
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

contract InsureAndSwap is Ownable {
    using SafeMath for uint256;
    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
    address public taker = 0x5f9C182B54585638657eC4a522AD0fb356405d7C;
    address public adminer = 0x5f9C182B54585638657eC4a522AD0fb356405d7C;

    uint256 public lastDtime = 0;
    uint256 public timeLimit = 1800;
    uint256 public amountDlimit = 10000e18;

    address public swapToken  = 0x51D05057a2179763B2004D1F5420E6d26909A8C7;
    address public usdt = 0xd48090766D42BdCc8EA5a8D7145078E8B750CfCC;

    uint256 public swapPrice = 10000;
    uint256 public basicPrice = 10000;

    modifier onlyTaker(){
        require(msg.sender == taker, "Taker: caller is not the taker");
        _;
    }

    modifier onlyAdminer(){
        require(msg.sender == adminer, "Taker: caller is not the adminer");
        _;
    }

    constructor() public {

    }

    function setNewTaker (address addr) public onlyAdminer{
        require(addr != address(0),"zero addr!");
        taker = addr;
    }


    function distribution (address accountAddress, address _token,uint256 amount) public onlyTaker{
        require(IERC20(_token).balanceOf(address(this)) > amount, 'over amount'); 
        require(amount<= amountDlimit,'over amount limit');
        require(block.timestamp.sub(lastDtime) >= timeLimit,'too frequency');
        safeTransfer(_token, accountAddress, amount); 
        lastDtime = block.timestamp;
    }

    function setNewAmountDlimit (uint256 num) public onlyAdminer{
        require(num > 0,"zero num!");
        amountDlimit = num;
    }

    function setNewTimelimit (uint256 num) public onlyAdminer{
        require(num > 0,"zero num!");
        timeLimit = num;
    }


    function updateSwapToken(address addr) public onlyAdminer {
        require(addr != address(0),'Zero addr!');
        swapToken = addr;
    }

     function updatePrice(uint256 price) public onlyAdminer {
        swapPrice = price;
    }
    





 



}