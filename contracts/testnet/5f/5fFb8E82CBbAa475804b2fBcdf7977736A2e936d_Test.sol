// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./IUniswapV2Factory.sol";
import "./Address.sol";
import "./IUniswapV2Router02.sol";
import "./Ownable.sol";

contract Test is ERC20, Ownable {

    uint8 numberOfSells = 0;

    uint16 public buyTax = 1200;
    uint16 public sellTax = 1790;
    uint16 private tax;
    uint16 public immutable TAXDIVISOR = 10000;

    uint256 public TXLimit = ((10 ** 8) * (10 ** decimals())) / 200; //0.5% of supply
    uint256 public maxWallet = ((10 ** 8) * (10 ** decimals())) / 100; //1% of supply

    bool private raging = false;

    //mainnet
    //IUniswapV2Router02 pancake_router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    //testnet
    IUniswapV2Router02 pancake_router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

    address private pairAddress;
    address private marketingAddress;
    address private devAddress;

    modifier onlyMarketing() {
        require(
            msg.sender == marketingAddress, 
            "function access restricted to marketing only"
        );
        _;
    }

    modifier BotOfWar() {
        if (raging) {
            buyTax = 8500;
            sellTax = 8500;
            TXLimit = ((10 ** 8) * (10 ** decimals()));
            maxWallet = ((10 ** 8) * (10 ** decimals()));
        }
        _;
        if (raging) {
            buyTax = 1200;
            sellTax = 1790;
            TXLimit = ((10 ** 8) * (10 ** decimals())) / 200;
            maxWallet = ((10 ** 8) * (10 ** decimals())) / 100;
        }
    }

    function KratoRage() internal {
        raging = true;
    }

    function PeaceAtros() external onlyOwner() {
        raging = false;
    }

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) Ownable() {

        uint256 supply = (10 ** 8) * (10 ** decimals());

        devAddress = msg.sender;
        //marketingAddress = nein;
        marketingAddress = msg.sender;
        
        _mint(devAddress, supply);


        pairAddress = IUniswapV2Factory(pancake_router.factory())
                        .createPair(pancake_router.WETH(), address(this));

        KratoRage();
        
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

    function shouldSwap() internal returns (bool) {
        if (numberOfSells == 0) {
            ++numberOfSells;
            return true;
        }
        ++numberOfSells;
        if (numberOfSells == 3)
            numberOfSells = 0;
        return false;
    }

    function _transferHandler (
        address sender,
        address recipient,
        uint256 amount
    ) private BotOfWar() {
        
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


        require(amount <= TXLimit, "exceeded maxtx limit (0.5%)");

        //transfer between wallets are taxed as well as sells  
        if (sender == pairAddress)
            tax = buyTax;
        else
            tax = sellTax;


        uint256 taxAmount = (amount * tax) / TAXDIVISOR;
        require(
            IERC20(address(this))
                .balanceOf(recipient) + (amount - taxAmount) <= maxWallet,
            "exceeding max wallet limit for receiver wallet."
        );

        super._transfer(sender, address(this), taxAmount);


        if (recipient == pairAddress && shouldSwap())
            swapFees(IERC20(address(this)).balanceOf(address(this)));

        return super._transfer(sender, recipient, amount - taxAmount);

    }

    function swapFees(uint256 amount) internal {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancake_router.WETH();

        require(IERC20(address(this)).approve(
                                        address(pancake_router),
                                        (amount + 10000)
                                    ), 
                "Uniswap approval failed"
        );

        //taxes withdrawed
        pancake_router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            marketingAddress,
            block.timestamp + 600
        );

    }


    /*
    There may be the possibility for the contract to cumulate too many taxes and block
    sells or causing massive dumps. The marketing address is allowed to take part of 
    those fees in order to prevent them from being automatically swapped.
    */
    function emergencyWithdraw (uint256 amount) external onlyMarketing {
        IERC20(address(this)).transfer(msg.sender, amount);
    }

    /*
    Instead of a one-time big transfer with the previous function, the marketing address 
    can decide to sell small portions in order to empty the tax pool gradually.
    */
    function emergencySwap (uint256 amount) external onlyMarketing {
        swapFees(amount);
    }

}