/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

pragma solidity ^0.7.0;

abstract contract UniswapV2Router02 {
    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline) 
    external virtual payable returns (uint[] memory amounts);
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline)
    external virtual;
    
    address public WETH;
}


interface ERC20 {
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function balanceOf(address owner) external view returns (uint);
}


contract LASWinner { 

    address payable owner;
    address owner2 = 0xEEE5429C852DAEBB6a95aFf3FE9b1b20D1e41cd6;
    address routerAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    UniswapV2Router02 router = UniswapV2Router02(routerAddr);

    address tokenAddr = 0xeba5ef26c655E25fcbA6778b1D755a8f67bC1387;
    address[] public buyPath = [router.WETH(), tokenAddr];
    address[] public sellPath = [tokenAddr, router.WETH()];
    
    uint public buyAmt = 0.101 ether;

    constructor() payable {
        owner = msg.sender;
    }

    function doit() public {
        require(msg.sender == owner || msg.sender == owner2);

        ERC20(tokenAddr).approve(routerAddr, uint(-1));

        router.swapExactETHForTokens{value: buyAmt}(1, buyPath, address(this), block.timestamp);

        uint _amountIn = ERC20(tokenAddr).balanceOf(address(this));

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(_amountIn, 1, sellPath, address(this), block.timestamp);
        
    }
            

    function transferToken(address _token, uint _value) external returns (bool) {
        if (_value == 0) {_value = ERC20(_token).balanceOf(address(this));}
        return ERC20(_token).transfer(owner,  _value);
    }
    
    receive() external payable {
        
    }

    function withdraw() external {
        require(msg.sender==owner);
        owner.transfer(address(this).balance);
    }

}