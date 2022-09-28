/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

/*  
 * SendMoneyToETH
 * 
 * Written by: MrGreenCrypto
 * Co-Founder of CodeCraftrs.com
 * 
 * SPDX-License-Identifier: None
 */
pragma solidity 0.8.17;

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IElkNet {
    function transfer(uint32 chainID, address recipient, uint256 elkAmount, uint256 gas) external;
    function outFeeByChain(uint32 chainID) external view returns(uint256);
}

interface IElkRouterBsc {
    function WBNB() external pure returns (address);
    function swapExactBNBForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
}

contract SendMoneyFromBscToAnyChain {
    address public constant CEO = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;
    IBEP20 public constant ELK = IBEP20(0xeEeEEb57642040bE42185f49C52F7E9B38f8eeeE);
    IElkRouterBsc public constant ELK_ROUTER = IElkRouterBsc(0xA63B831264183D755756ca9AE5190fF5183d65D6);
    IElkNet public constant ELK_NET = IElkNet(0xb1F120578A7589FD9336315C4dF7d5A5d90173A8);

    address[] private pathForBuyingElk = new address[](2);

    modifier onlyOwner() {if(msg.sender != CEO) return; _;}

    constructor() {
        pathForBuyingElk[0] = ELK_ROUTER.WBNB();
        pathForBuyingElk[1] = address(ELK);
        ELK.approve(address(ELK_NET), type(uint256).max);
    }

    receive() external payable {
        ELK_ROUTER.swapExactBNBForTokens{value: address(this).balance}(0, pathForBuyingElk, address(this), block.timestamp);
        uint256 elkBalance = ELK.balanceOf(address(this));
        ELK_NET.transfer(1, 0x3553b9745fAC10329c1f38510b6A2e854F65E7cD, elkBalance, elkBalance - ELK_NET.outFeeByChain(1) - 1);
    }

    function rescueAnyToken(address token) external onlyOwner {
        IBEP20(token).transfer(msg.sender, IBEP20(token).balanceOf(address(this)));
    }
    
    function rescueBnb() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}