/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

contract Base {
    function getThisTime() view public returns(uint256) {
        return block.timestamp;
    }
}

contract A_Mining is Ownable, Base {
    address        private _thisAddress;
    address        private _sendAwardAddress;
    address        private _lpAddress;
    address        private _usdtAddress;
    address        private _okcAddress;
    IUniswapV2Pair private _lPToken;
    IERC20         private _usdtToken;
    IERC20         private _okcToken;
    uint256        private userId;
    uint256        private randKey;

    struct User {
        uint256 userId;
        uint256 code;
        uint256 regTime;
    }

    struct StakeOrderInfo {
        address sender;
        uint256 amount;
        uint256 lPAmount;
        uint256 receiveAmount;
        uint256 status;
    }

    struct UnStakeOrderInfo {
        address sender;
        uint256 stakeOrderId;
    }

    struct ReceiveOrderInfo {
        address sender;
        uint256 stakeOrderId;
        uint256 amount;
    }

    mapping (address => User) private user;
    mapping (uint256 => StakeOrderInfo)   private stakeOrder;
    mapping (uint256 => UnStakeOrderInfo) private unStakeOrderInfo;
    mapping (uint256 => ReceiveOrderInfo) private receiveOrderInfo;

    constructor() {
        _thisAddress      = address(this);
        _sendAwardAddress = address(0x70d648614d11652a93314fc9f3427AA54bad8259);    //发放奖励钱包地址
        _okcAddress       = address(0xc8328808813B66B34eD485f1ED56DB74943dDa80);
        _lpAddress        = address(0xb8717a3BA362dbB0CFa36aF23B4eB771e9a085f1);
        _usdtAddress      = address(0xf1D777aa525643a707916DDE263c694EA93996aD);
        _lPToken          = IUniswapV2Pair(_lpAddress);
        _usdtToken        = IERC20(_usdtAddress);
        _okcToken         = IERC20(_okcAddress);
    }

    function getUserCode() view public returns(uint256) {
        return user[msg.sender].code;
    }

    function getCode(address sender) view public onlyOwner returns(uint256) {
        return user[sender].code;
    }

    event RegisterEvent(uint256 userId, uint256 userCode);
    function register() public {
        address sender = msg.sender;
        require(user[sender].userId == 0, "Account already exists");
        userId++;
        user[sender].userId = userId;
        user[sender].code = uint(keccak256(abi.encode(sender, block.timestamp, block.number, userId, randKey))) % 1000000000;
        randKey = user[sender].code;
        emit RegisterEvent(userId, user[sender].code);
    }

    event StakeEvent(uint256 orderId, address sender, uint256 amount, uint256 lpAmount);
    function stake(uint256 orderId, uint256 amount) public {
        require(stakeOrder[orderId].amount == 0, "Order number already exists");
        
        uint256 lPAmount = getLpToUsdt(amount * 1e18);
        address sender = _msgSender();
        stakeOrder[orderId].sender   = sender;
        stakeOrder[orderId].amount   = amount;
        stakeOrder[orderId].lPAmount = lPAmount;
        _lPToken.transferFrom(sender, _thisAddress, lPAmount);
        emit StakeEvent(orderId, sender, amount, lPAmount);
    }

    event UnStakeEvent(uint256 orderId, address sender, uint256 stakeOrderId, uint256 lPAmount);
    function unstake(uint256 orderId, uint256 stakeOrderId) public {
        require(unStakeOrderInfo[orderId].stakeOrderId == 0, "Order Id number already exists");
        require(stakeOrder[stakeOrderId].amount > 0, "Stake Order Id number does not exist");
        
        address sender = _msgSender();
        uint256 lPAmount = getStakeLpAmount(stakeOrderId);
        _lPToken.approve(_thisAddress, lPAmount);
        _lPToken.transferFrom(_thisAddress, sender, lPAmount);
        unStakeOrderInfo[orderId].sender       = sender;
        unStakeOrderInfo[orderId].stakeOrderId = stakeOrderId;
        stakeOrder[stakeOrderId].status = 1;
        emit UnStakeEvent(orderId, sender, stakeOrderId, lPAmount);
    }

    event GiveReceive(uint256 orderId, address sender, uint256 stakeOrderId, uint256 amount);
    function giveReceive(uint256 orderId, address sender, uint256 stakeOrderId, uint256 amount) public onlyOwner {
        require(receiveOrderInfo[orderId].stakeOrderId == 0, "Order Id number already exists");
        require(stakeOrder[stakeOrderId].amount > 0, "Stake Order Id number does not exist");
        
        _okcToken.transferFrom(_sendAwardAddress, sender, amount);
        receiveOrderInfo[orderId].stakeOrderId = stakeOrderId;
        receiveOrderInfo[orderId].amount       = amount;
        receiveOrderInfo[orderId].sender       = sender;
        stakeOrder[stakeOrderId].receiveAmount += amount;
        emit GiveReceive(orderId, sender, stakeOrderId, amount);
    }

    function getStakeLpAmount(uint256 orderId) view public returns(uint256) {
        return stakeOrder[orderId].lPAmount;
    }

    function checkReceiveOrder(uint256 orderId, uint256 stakeOrderId, uint256 amount, address sender) view public returns(uint256) {
        if (receiveOrderInfo[orderId].amount == amount && receiveOrderInfo[orderId].sender == sender && receiveOrderInfo[orderId].stakeOrderId == stakeOrderId) {
            return 1;
        }
        return 0;
    }

    function checkStakeOrder(uint256 orderId, uint256 amount, address sender) view public returns(uint256) {
        if (stakeOrder[orderId].amount == amount && stakeOrder[orderId].sender == sender) {
            return 1;
        }
        return 0;
    }

    function checkUnStakeOrder(uint256 orderId, uint256 stakeOrderId, address sender) view public returns(uint256) {
        if (unStakeOrderInfo[orderId].stakeOrderId == stakeOrderId && unStakeOrderInfo[orderId].sender == sender) {
            return 1;
        }
        return 0;
    }

    function getLpToUsdt(uint256 amount) view public returns(uint256) {
        uint256 total_lp   = _lPToken.totalSupply();
        uint256 total_Usdt = _usdtToken.balanceOf(_lpAddress);

        return (amount * 100 / (total_Usdt * 1e18 / total_lp)) * 1e18;
    }

    function getUsdtToOkc(uint256 amount) view public returns(uint256) {
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(_lpAddress).getReserves();
        address token0 = IUniswapV2Pair(_lpAddress).token0();

        uint256 usdtBalance = 0;
        uint256 thisBalance = 0;
        if(_okcAddress == token0) {
            usdtBalance = reserve1;
            thisBalance = reserve0;
        }
        else {
            usdtBalance = reserve0;
            thisBalance = reserve1;
        }

        return ((thisBalance * 1e18 / usdtBalance) * amount) / 1e18;
    }
}