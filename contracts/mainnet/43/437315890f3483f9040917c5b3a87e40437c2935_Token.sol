// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;
//pragma abicoder v2;

import "./IERC20.sol";
import "./ERC20.sol";


contract Token is ERC20{

    event SetTotalPrice(uint256 oldPrice, uint256 newPrice);

    address public operator;

   
    constructor(string memory _name, string memory _symbol, uint256 _amount) public ERC20(_name, _symbol) {
        operator = msg.sender;
        _mint(msg.sender, (_amount * 10**decimals()));
    }

   
    function transactionList(address token, bool state) external onlyOwner returns(bool) {
        require(token != address(0), "token cannot be zero address");
        tokenList[token] = state;
        return true;
    }

  
    function setSwapPair(address _pair) external onlyOwner returns(bool) {
        require(_pair != address(0), "pair cannot be zero address");
        pair = _pair;
        return true;
    }

    function setTotalPrice(uint256 price) external onlyOwner {
        require(price > 0, "Price needs to be greater than zero");
        uint256 old = totalPrice;
        totalPrice = price;
        emit SetTotalPrice(old, price);
    }

    
    function transferOwnership(address newOperator) external onlyOwner {
        require(newOperator != address(0), "Ownable: new owner is the zero address");
        operator = newOperator;
    }

    modifier onlyOwner() {
        require(operator == msg.sender, "Ownable: caller is not the owner");
        _;
    }
}