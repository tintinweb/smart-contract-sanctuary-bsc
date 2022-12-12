/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.1;

interface PancakeRouter {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface BEP20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract PTMedium is Ownable {
    address public ptAddress;
    address private _usdtAddress;
    address private _pancakeRouterAddress;
    PancakeRouter private _pancakeRouter;

    constructor(address _address,uint256 amount) {
        ptAddress = _address;
        _usdtAddress = 0x9C611e2df859032a0fB4911074c4Feac84aA38DF;
        _pancakeRouterAddress = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;

        _pancakeRouter = PancakeRouter(_pancakeRouterAddress);

        BEP20 token = BEP20(_address);
        token.approve(_pancakeRouterAddress, amount);
    }

    function exchangeUsdt(uint256 _number) public returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = ptAddress;
        path[1] = _usdtAddress;
        uint256[] memory exchange_usdt = _pancakeRouter
            .swapExactTokensForTokens(
                _number,
                0,
                path,
                address(this),
                block.timestamp + 86400
            );
        BEP20(_usdtAddress).transfer(ptAddress, exchange_usdt[1]);
        return exchange_usdt[1];
    }
}