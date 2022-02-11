// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./IUniswapV2Factory.sol";
import "./Address.sol";
import "./IUniswapV2Router02.sol";

contract token is ERC20 {

    uint256 private cumulativeTax = 0;

    struct Fees {
        uint16 devTax;
        uint16 marketingTax;
    }

    Fees private buyFees = Fees(
        200,
        1000
    );

    Fees private  sellFees = Fees(
        290,
        1500
    );

    Fees private fees;

    uint16 private constant TAXDIVISOR = 10000;

    //mainnet
    //IUniswapV2Router02 pancake_router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    //testnet
    IUniswapV2Router02 pancake_router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

    address private pairAddress;
    address private devAddress;
    address private marketingAddress = address(0xdead);


    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        _mint(msg.sender, (10 ** 8) * (10 ** decimals()) );
        pairAddress = IUniswapV2Factory(pancake_router.factory())
                        .createPair(pancake_router.WETH(), address(this));
        devAddress = msg.sender;
        marketingAddress = msg.sender;
    }

    function transfer(
        address recipient, 
        uint256 amount) public virtual override returns (bool) {
        _transferHandler(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = allowance(sender, _msgSender());
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transferHandler(sender, recipient, amount);

        return true;
    }

    function _transferHandler (
        address sender,
        address recipient,
        uint256 amount
    ) private {
        
        //check tax-free addresses

        if (sender == address(0x0) 
            || recipient == address(0x0)
            || sender == devAddress
            || recipient == devAddress
            || sender == marketingAddress
            || recipient == marketingAddress
            || sender == address(0xdead)
            || recipient == address(0xdead)
            || sender == address(this)
            || recipient == address(this)
        )
            return super._transfer(sender, recipient, amount);

        //maxTX 0.2% of total supply for sells
        if (recipient == pairAddress)
            require(amount <= totalSupply() / 500);

        //transfer between wallets are taxed as well as sells  
        if (sender == pairAddress)
            fees = buyFees;
        else
            fees = sellFees;
        
        uint256 devAmount = (amount * fees.devTax) / TAXDIVISOR;
        uint256 marketingAmount = (amount * fees.marketingTax) / TAXDIVISOR;

        super._transfer(sender, address(this), devAmount + marketingAmount);

        if (recipient == pairAddress) {

            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = pancake_router.WETH();

            require(IERC20(address(this)).approve(
                                            address(pancake_router),
                                            (cumulativeTax + devAmount + marketingAmount + 10000)
                                        ), 
                    "Uniswap approval failed"
            );

            //taxes for current sell
            pancake_router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                devAmount,
                0,
                path,
                devAddress,
                block.timestamp + 600
            );
            pancake_router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                marketingAmount,
                0,
                path,
                marketingAddress,
                block.timestamp + 600
            );

            //taxes for previous buys
            if (cumulativeTax > 0) {

                uint256 _cumulativeBuyDevTaxes = cumulativeTax * buyFees.devTax / (buyFees.devTax + buyFees.marketingTax);
                uint256 _cumulativeBuyMarketingTaxes = cumulativeTax - _cumulativeBuyDevTaxes;
                pancake_router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                    _cumulativeBuyDevTaxes,
                    0,
                    path,
                    devAddress,
                    block.timestamp + 600
                );
                pancake_router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                   _cumulativeBuyMarketingTaxes,
                    0,
                    path,
                    marketingAddress,
                    block.timestamp + 600
                );

                cumulativeTax = 0;
            }
        }
        else {
            cumulativeTax = cumulativeTax + devAmount + marketingAmount;
        }

        return super._transfer(sender, recipient, (amount - devAmount) - marketingAmount);

    }

}