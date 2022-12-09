/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

pragma solidity =0.8.0;

interface BEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address to, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed from, address indexed to);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Ownable: Caller is not the owner");
        _;
    }

    function transferOwnership(address transferOwner) external onlyOwner {
        require(transferOwner != newOwner);
        newOwner = transferOwner;
    }

    function acceptOwnership() virtual public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferBNB(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}

contract BEP20ToERC20Wrapper is Ownable {
    struct WrapInfo {
        address from;
        uint amount;
        uint fee;
        uint ethNonce;
    }

    BEP20 public immutable NBU;
    uint public minUnwrapAmount;

    mapping(address => uint) public userWrapNonces;
    mapping(address => uint) public userUnwrapNonces;
    mapping(address => mapping(uint => uint)) public ethToBscWrapNonces;
    mapping(address => mapping(uint => WrapInfo)) public wraps;
    mapping(address => mapping(uint => uint)) public unwraps;

    event Wrap(address indexed user, uint indexed unwrapNonce, uint indexed bscNonce, uint amount, uint fee);
    event Unwrap(address indexed user, uint indexed wrapNonce, uint amount);
    event UpdateMinUnwrapAmount(uint indexed amount);
    event Rescue(address indexed to, uint amount);
    event RescueToken(address indexed token, address indexed to, uint amount);

    constructor(address nbu) {
        NBU = BEP20(nbu);
    }
    
    function unwrap(uint amount) external {
        require(amount >= minUnwrapAmount, "BEP20ToERC20Wrapper: Value too small");
        
        NBU.transferFrom(msg.sender, address(this), amount);
        uint userUnwrapNonce = ++userUnwrapNonces[msg.sender];
        unwraps[msg.sender][userUnwrapNonce] = amount;
        emit Unwrap(msg.sender, userUnwrapNonce, amount);
    }

    function wrap(address user, uint amount, uint fee, uint ethNonce) external onlyOwner {
        require(user != address(0), "BEP20ToERC20Wrapper: Can't be zero address");
        require(ethToBscWrapNonces[user][ethNonce] == 0, "BEP20ToERC20Wrapper: Already processed");
        
        NBU.transfer(user, amount - fee);
        uint wrapNonce = ++userWrapNonces[user];
        ethToBscWrapNonces[user][ethNonce] = wrapNonce;
        wraps[user][wrapNonce].amount = amount;
        wraps[user][wrapNonce].fee = fee;
        wraps[user][wrapNonce].ethNonce = ethNonce;
        emit Wrap(user, wrapNonce, ethNonce, amount, fee);
    }
    

    //Admin functions
    function rescue(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0), "BEP20ToERC20Wrapper: Can't be zero address");
        require(amount > 0, "BEP20ToERC20Wrapper: Should be greater than 0");
        TransferHelper.safeTransferBNB(to, amount);
        emit Rescue(to, amount);
    }

    function rescue(address to, address token, uint256 amount) external onlyOwner {
        require(to != address(0), "BEP20ToERC20Wrapper: Can't be zero address");
        require(amount > 0, "BEP20ToERC20Wrapper: Should be greater than 0");
        TransferHelper.safeTransfer(token, to, amount);
        emit RescueToken(token, to, amount);
    }

    function updateMinUnwrapAmount(uint amount) external onlyOwner {
        require(amount > 0, "BEP20ToERC20Wrapper: Should be greater than 0");
        minUnwrapAmount = amount;
        emit UpdateMinUnwrapAmount(amount);
    }
}