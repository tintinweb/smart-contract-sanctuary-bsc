// SPDX-License-Identifier: UNLICENSED

import "Context.sol";
import "Ownable.sol";
import "SafeMath.sol";
import "Address.sol";
import "ERC20.sol";
import "IERC721.sol";
import "IUniswapV2Router02.sol";


pragma solidity ^0.7.6;

contract TokenERC20 is Ownable, ERC20 {
    using SafeMath for uint256;

    uint256 public buyFeeRate = 1;
    uint256 public treasuryFee = 10;
    uint256 public stakingFee = 5;
    uint256 public constant feeDenominator = 100;
    
    uint256 public antiWhaleAmount;
    uint256 public antiWhaleStartTime;
    uint256 public constant antiWhaleDuration = 15 minutes;

    address public treasuryAddress = 0x5796faca11816d360844b4346b62FBcdE53ED3Aa;
    address public stakingAddress = _msgSender();

    mapping(address => bool) public presaleAddress;

    constructor(string memory name, string memory symbol, uint8 decimals) 
        ERC20(name, symbol, decimals) Ownable(treasuryAddress) { }

    function setAntiWhaleAmount(uint256 _amount) public onlyTreasury { // set anti whale amount also activate antibot
        require(antiWhaleAmount == 0, "Can active antiWhale once"); // antiWhale can only activate once
        antiWhaleAmount = _amount;
        antiWhaleStartTime = block.timestamp - 10; // safty margin 10s
    }
    function isAntiWhaleEnded() public view returns (bool) { return block.timestamp > antiWhaleStartTime + antiWhaleDuration; }

    function setTransferFeeRate(uint256 _buyFeeRate, uint256 _treasuryFeeRate, uint256 _stakeFeeRate) public onlyTreasury {
        require(_buyFeeRate <= 1, "BUY_FEE_RATE_NO_HIGHER_THAN_1_PERCENT");
        require(_stakeFeeRate + _treasuryFeeRate <= 15, "SELL_FEE_RATE_NO_HIGHER_THAN_15_PERCENT");
        buyFeeRate = _buyFeeRate;
        treasuryFee = _treasuryFeeRate;
        stakingFee = _stakeFeeRate;
    }

    function setFeeAddresss(address _treasuryAddress, address _stakingAddress) external onlyTreasury {
        treasuryAddress = _treasuryAddress;
        stakingAddress = _stakingAddress;
    }

    function setPresaleAddress(address _presaleAddress) public onlyTreasury {
        presaleAddress[_presaleAddress] = true;
    }

    function sweepBNB(address _to) public onlyTreasury { payable(_to).transfer(address(this).balance); }
    function sweepToken(address _token, address _to) public onlyTreasury { IERC20(_token).transfer(_to, IERC20(_token).balanceOf(address(this))); }
}

contract MovingOn is TokenERC20 {
    using SafeMath for uint256;
    using Address for address;

    uint256 public constant DECIMALS = 18;

    IUniswapV2Router02 public uniswapV2Router;

    uint256 public constant maxSupply = 100 * 10**6 * 10**18;
    
    address public uniswapV2Pair;

    constructor() TokenERC20("MovingOn Finance", "MOVON", uint8(DECIMALS)) {
        _mint(_msgSender(), maxSupply);
        
        // uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); //bsc router
        uniswapV2Router = IUniswapV2Router02(0xBBe737384C2A26B15E23a181BDfBd9Ec49E00248); //pink router

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
             .createPair(address(this), uniswapV2Router.WETH());
    }

    function burn(uint256 amount) public { _burn(_msgSender(), amount); }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {

        if (isAntiWhaleEnded()) { require(amount <= antiWhaleAmount, "PUMPING_IS_NOT_ALLOWED"); }

        uint256 _amount = shouldTakeFee(sender, recipient)
            ? takeFee(sender, amount)
            : amount;

        super._transfer(sender, recipient, _amount); // TransferFee
    }

    function shouldTakeFee(address from, address to) internal view returns (bool) { 
        return (from != address(this) && to != address(this)) && (uniswapV2Pair == from || uniswapV2Pair == to) && !presaleAddress[from];
    }

    function takeFee(address sender, uint256 _amount) internal returns (uint256) {
        bool isBuy = uniswapV2Pair == sender;
        uint256 _buyFeeRate = isBuy ? buyFeeRate : 0;
        uint256 _treasuryFee = isBuy ? 0 : treasuryFee;
        uint256 _stakeFee = isBuy ? 0 : stakingFee;
        uint256 _totalFee = _buyFeeRate.add(_treasuryFee).add(_stakeFee);
        uint256 feeAmount = _amount.mul(_totalFee).div(feeDenominator);

        if (isBuy) { super._transfer(sender, address(this), feeAmount); } // TransferFee
        else {
            // stake
            uint256 stakeAmount = _amount.mul(_stakeFee).div(feeDenominator);
            super._transfer(sender, stakingAddress, stakeAmount);

            // treasury
            uint256 amountToSwap = feeAmount.sub(stakeAmount);
            
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = uniswapV2Router.WETH();

            uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                amountToSwap,
                0,
                path,
                treasuryAddress,
                block.timestamp + 20
            );
        }

        emit Transfer(sender, address(this), feeAmount);
        return _amount.sub(feeAmount);
    }

    // receivable token
    receive() external payable {}
}