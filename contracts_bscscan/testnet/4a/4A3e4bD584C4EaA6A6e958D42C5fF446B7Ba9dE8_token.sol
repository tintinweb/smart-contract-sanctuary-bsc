// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./IPancakeFactory.sol";
import "./Address.sol";
import "./IPancakeRouter02.sol";

contract token is ERC20 {

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
    //IPancakeFactory pancake_factory = IPancakeFactory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
    //IPancakeRouter02 pancake_router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    //testnet
    IPancakeFactory pancake_factory = IPancakeFactory(0x182859893230dC89b114d6e2D547BFFE30474a21);
    IPancakeRouter02 pancake_router = IPancakeRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);

    address private pairAddress;
    address private devAddress;
    address private marketingAddress = address(0xdead);

    //mainnet
    //address constant WBNB_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    //testnet
    address constant WBNB_ADDRESS = 0xBdf1a2e17DECb2aAC725F0A1C8C4E2205E70719C;

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        _mint(msg.sender, (10 ** 8) * (10 ** decimals()) );
        pairAddress = pancake_factory.createPair(WBNB_ADDRESS, address(this));
        devAddress = msg.sender;
        marketingAddress = msg.sender;
        //mainnet
        //_approve(address(this), 0x10ED43C718714eb63d5aA57B78B54704E256024E, type(uint256).max);
        //testnet
        _approve(address(this), 0xD99D1c33F9fC3444f8101754aBC46c52416550D1, type(uint256).max);
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

        address[] memory path = new address[](2);
        path[1] = WBNB_ADDRESS;
        path[2] = address(this);

        super._transfer(sender, address(this), devAmount + marketingAmount);

        pancake_router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            devAmount,
            0,
            path,
            devAddress,
            block.timestamp + 1 minutes
        );
        pancake_router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            marketingAmount,
            0,
            path,
            marketingAddress,
            block.timestamp + 1 minutes
        );

        return super._transfer(sender, recipient, (amount - devAmount) - marketingAmount);

    }

}