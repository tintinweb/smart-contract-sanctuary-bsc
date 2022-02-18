/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

pragma solidity >=0.6.0 <0.9.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakePair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
}

interface IPancakeERC20 {
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
}

contract autoSwap {
    event DepositBNB(address indexed sender, uint value);
    event WithdrawBNB(address indexed sender, uint value);

    address private _owner;

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor() public {
        _owner = msg.sender;
    }

    receive() external payable {}

    function depositBNB() external payable {
        emit DepositBNB(msg.sender, msg.value);
    }

    function withdrawBNB(uint256 amount) external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance >= amount, "amount must less than balance");
        payable(msg.sender).transfer(amount);
        emit WithdrawBNB(msg.sender, amount);
    }

    function bnbBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function withdraw(address token, uint256 amount) public onlyOwner returns (uint8) {
        require(amount > 0, "amount must greater than 0");
        IERC20(token).transfer(owner(), amount);
        return 0;
    }

    function withdrawAll(address token) public onlyOwner returns (uint8) {
        uint256 amount =  IERC20(token).balanceOf(address(this));
        require(amount > 0, "amount must greater than 0");
        IERC20(token).transfer(owner(), amount);
        return 0;
    }

    function balanceOf(address token) public view onlyOwner returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function getReserves(address token) external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) {
        return IPancakePair(token).getReserves();
    }

    function swapDouble(address pair0, address pair1, uint amount0In, uint amount1In, uint amount0Out0, uint amount1Out0, uint amount0Out1, uint amount1Out1) external onlyOwner {
        require(pair0 != pair1, 'Same pair address');
        (address pair0Token0, address pair0Token1) = (IPancakePair(pair0).token0(), IPancakePair(pair0).token1());
        (address pair1Token0, address pair1Token1) = (IPancakePair(pair1).token0(), IPancakePair(pair1).token1());
        require(pair0Token0 < pair0Token1 && pair1Token0 < pair1Token1, 'Non standard uniswap AMM pair');
        require(pair0Token0 == pair1Token0 && pair0Token1 == pair1Token1, 'Require same token pair');

        if (amount0In > 0) IPancakeERC20(pair0Token0).transfer(pair0, amount0In);
        if (amount1In > 0) IPancakeERC20(pair0Token1).transfer(pair0, amount1In);
        IPancakePair(pair0).swap(amount0Out0, amount1Out0, pair1, new bytes(0));
        IPancakePair(pair1).swap(amount0Out1, amount1Out1, address(this), new bytes(0));
    }

    function swapToken(address pair, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address to) external onlyOwner {
        address token0 = IPancakePair(pair).token0();
        address token1 = IPancakePair(pair).token1();

        if (amount0In > 0) IPancakeERC20(token0).transfer(pair, amount0In);
        if (amount1In > 0) IPancakeERC20(token1).transfer(pair, amount1In);
        IPancakePair(pair).swap(amount0Out, amount1Out, to, new bytes(0));
    }
    
}