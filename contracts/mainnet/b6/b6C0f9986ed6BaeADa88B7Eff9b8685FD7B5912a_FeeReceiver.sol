//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./IUniswapV2Router02.sol";

interface IOwnedContract {
    function getOwner() external view returns (address);
    function burn(uint256 amount) external;
}

contract FeeReceiver {

    // Token
    IERC20 public immutable token;

    // Recipients Of Fees
    address public NFT;
    address public SKPFund;

    // Fee Percentages
    uint256 public NFTPercent         = 50;
    uint256 public skepticFundPercent = 50;
    uint256 public bountyPercent      = 2;

    // router
    IUniswapV2Router02 router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    // Token -> BNB
    address[] path;

    modifier onlyOwner(){
        require(
            msg.sender == IOwnedContract(address(token)).getOwner(),
            'Only Token Owner'
        );
        _;
    }

    constructor(address token_, address NFT_, address SKPFund_) {
        token = IERC20(token_);
        NFT = NFT_;
        SKPFund = SKPFund_;

        // Sell Path
        path = new address[](2);
        path[0] = token_;
        path[1] = router.WETH();

    }

    function trigger() external {

        // Bounty Reward For Triggerer
        uint bounty = currentBounty();
        if (bounty > 0) {
            token.transfer(msg.sender, bounty);
        }

        // Token Balance In Contract
        uint balance = token.balanceOf(address(this));

        if (balance > 0) {
            
            // Sell Tokens For BNB
            IERC20(token).approve(address(router), balance);
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(balance, 0, path, address(this), block.timestamp + 300);

            // send NFT rewards
            _send(NFT, address(this).balance * NFTPercent / 100);
            
            // send Fund Rewards
            _send(SKPFund, address(this).balance);
            
        }
    }

    function updateFeePercentages(uint fund_, uint nft_) external onlyOwner {
        require(
            fund_ + nft_ == 100, 'Invalid Fees'
        );
        skepticFundPercent = fund_;
        NFTPercent = nft_;
    }

    function setBountyPercent(uint256 bountyPercent_) external onlyOwner {
        require(bountyPercent_ < 100);
        bountyPercent = bountyPercent_;
    }

    function setFund(address fund_) external onlyOwner {
        require(fund_ != address(0));
        SKPFund = fund_;
    }
    
    function setNFT(address nft_) external onlyOwner {
        require(nft_ != address(0));
        NFT = nft_;
    }
    
    function withdraw() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }
    
    function withdraw(address _token) external onlyOwner {
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }

    function _send(address to, uint val) internal {
        if (val > 0) {
            (bool s,) = payable(to).call{value: val}("");
            require(s);
        }
    }

    receive() external payable {}

    function currentBounty() public view returns (uint256) {
        uint balance = IERC20(token).balanceOf(address(this));
        return ((balance * bountyPercent ) / 100);
    }
}