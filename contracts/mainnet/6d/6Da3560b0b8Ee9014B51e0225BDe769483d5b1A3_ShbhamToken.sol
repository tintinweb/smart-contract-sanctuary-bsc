// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";


contract ShbhamToken is ERC20, Ownable {

    IUniswapV2Router02 private _uniswapV2Router;
    address            private _uniswapV2Pair;

    mapping (address => bool) whitelisted;

    bool private isSaleable;

    constructor() ERC20("shbham Token", "ST2") {
        isSaleable = true;
        _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); // BSC Testnet

        _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());   //Change Addres

        whitelisted[msg.sender] = true;

        _mint(msg.sender, 100000 * 10 ** decimals());

    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function addtowhitelist(address user) public onlyOwner{
        whitelisted[user] = true;
    }

    function removefromwhitelist(address user) public onlyOwner{
        whitelisted[user] = false;
    }

    function iswhitelisted(address user) public view returns(bool){
        return whitelisted[user];
    }

    function startSale() public onlyOwner{
        isSaleable = true;
    }

    function stopSale() public onlyOwner{
        isSaleable = false;
    }

    function salesatus() public view returns(bool){
        return isSaleable;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override
    {
        if(to == _uniswapV2Pair){
            if(isSaleable || whitelisted[from]){
                super._beforeTokenTransfer(from, to, amount);
            }
            else {
                 revert("sale has been stopped");
            }
        }
        else{
        super._beforeTokenTransfer(from, to, amount);
        }
    }
}