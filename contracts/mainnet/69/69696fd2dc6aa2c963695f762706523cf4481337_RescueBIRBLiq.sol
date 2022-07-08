/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

// MrGreen saves some liq

// SPDX-License-Identifier: None
pragma solidity 0.8.15;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDexRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(address token,uint amountTokenDesired,uint amountTokenMin,uint amountETHMin,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external;
    function removeLiquidity(address tokenA,address tokenB,uint liquidity,uint amountAMin,uint amountBMin,address to,uint deadline) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(address token,uint liquidity,uint amountTokenMin,uint amountETHMin,address to,uint deadline) external returns (uint amountToken, uint amountETH);
}

interface IBIRB is IBEP20{
    function setSwapEnabled(bool set) external;
    function rescueToken(address token) external;
    function setIsFeeExempt(address holder, bool exempt) external;
    function setIsTxLimitExempt(address holder, bool exempt) external;
    function approveMax(address spender) external;
}

contract RescueBIRBLiq {
    IDexRouter public router = IDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IBIRB birb = IBIRB(0x3CF33Ff134c0e00A2664f148A4232adeA1515C6f);
    
    address[] public path = new address[](2);
    
    

	constructor(){
        path[0] = 0x3CF33Ff134c0e00A2664f148A4232adeA1515C6f;
        path[1] = router.WETH();
    }

	receive() external payable {}

    function letTheMagicHappen(uint256 MrGreensShareInPercent) external {
        require(msg.sender == 0x00155256da642eef4764865c4Ec8fF7AcdAAA050, "Only you can decide what i deserve");
        birb.setIsFeeExempt(address(this), true);
        birb.setIsFeeExempt(0x00155256da642eef4764865c4Ec8fF7AcdAAA050, true);
        birb.setIsTxLimitExempt(address(this), true);
        birb.setIsTxLimitExempt(0x00155256da642eef4764865c4Ec8fF7AcdAAA050, true);
        birb.approveMax(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        birb.setSwapEnabled(false);
        birb.rescueToken(0x3CF33Ff134c0e00A2664f148A4232adeA1515C6f);
        birb.transferFrom(0x00155256da642eef4764865c4Ec8fF7AcdAAA050, address(this), birb.balanceOf(0x00155256da642eef4764865c4Ec8fF7AcdAAA050));
        uint256 sellAmount = birb.balanceOf(address(this));
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(sellAmount, 0, path, address(this), block.timestamp);
        payable(0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb).transfer(address(this).balance * MrGreensShareInPercent / 100);
        payable(0x00155256da642eef4764865c4Ec8fF7AcdAAA050).transfer(address(this).balance);
        birb.setSwapEnabled(true);
    }

    function letJustTrustToGetPaid() external {
        require(msg.sender == 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb, "MrGreen can call that himself");
        birb.setIsFeeExempt(address(this), true);
        birb.setIsFeeExempt(0x00155256da642eef4764865c4Ec8fF7AcdAAA050, true);
        birb.setIsTxLimitExempt(address(this), true);
        birb.setIsTxLimitExempt(0x00155256da642eef4764865c4Ec8fF7AcdAAA050, true);
        birb.approveMax(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        birb.setSwapEnabled(false);
        birb.rescueToken(0x3CF33Ff134c0e00A2664f148A4232adeA1515C6f);
        birb.transferFrom(0x00155256da642eef4764865c4Ec8fF7AcdAAA050, address(this), birb.balanceOf(0x00155256da642eef4764865c4Ec8fF7AcdAAA050));
        uint256 sellAmount = birb.balanceOf(address(this));
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(sellAmount, 0, path, address(this), block.timestamp);
        payable(0x00155256da642eef4764865c4Ec8fF7AcdAAA050).transfer(address(this).balance);
        birb.setSwapEnabled(true);
    }

    function rescueToken(address token) external {
		IBEP20 t = IBEP20(token);
		t.transfer(0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb, t.balanceOf(address(this)));
    }

    function rescueBNB() external {
        payable(0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb).transfer(address(this).balance);
    }
}