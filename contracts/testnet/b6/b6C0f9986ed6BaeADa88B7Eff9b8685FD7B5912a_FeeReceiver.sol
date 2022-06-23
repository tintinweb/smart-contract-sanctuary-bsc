//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./IUniswapV2Router02.sol";

interface IOwnableToken {
    function getOwner() external view returns (address);
    function burn(uint256 amount) external;
}

contract FeeReceiver {

    // token
    address public immutable token;

    // router
    IUniswapV2Router02 router;

    // Recipients Of Fees
    address public burnFund;
    address public NFTAddr;

    // Token -> BNB
    address[] path;

    /**
        Minimum Amount Of SKP In Contract To Trigger `trigger` Unless `approved`
            If Set To A Very High Number, Only Approved May Call Trigger Function
            If Set To A Very Low Number, Anybody May Call At Their Leasure
     */
    uint256 public minimumTokensRequiredToTrigger;

    // Burn Fund Allocation
    uint256 public burnFundPercentage;

    // Percentage of tokens to burn before selling
    uint256 public burnPercentage;

    // Address => Can Call Trigger
    mapping ( address => bool ) public approved;

    // Events
    event Approved(address caller, bool isApproved);

    modifier onlyOwner(){
        require(
            msg.sender == IOwnableToken(token).getOwner(),
            'Only Owner'
        );
        _;
    }

    constructor(address token_, address burnFund_, address NFTAddr_, address router_) {
        require(
            token_ != address(0) &&
            burnFund_ != address(0) &&
            NFTAddr_ != address(0),
            'Zero Address'
        );

        // Initialize Addresses
        token = token_;
        burnFund = burnFund_;
        NFTAddr = NFTAddr_;
        router = IUniswapV2Router02(router_);

        // Sell Path
        path = new address[](2);
        path[0] = token_;
        path[1] = router.WETH();

        // set initial approved
        approved[msg.sender] = true;

        // tax percentages
        burnPercentage = 10;
        burnFundPercentage = 65;

        // only approved can trigger at the start
        minimumTokensRequiredToTrigger = 10**30;
    }

    function trigger() external {

        // Token Balance In Contract
        uint balance = IERC20(token).balanceOf(address(this));

        if (balance < minimumTokensRequiredToTrigger && !approved[msg.sender]) {
            return;
        }
        
        uint toBurn = balance * burnPercentage / 100;
        if (toBurn > 0) {
            IOwnableToken(token).burn(toBurn);
        }
        balance -= toBurn;
        // sell Tokens in contract for BNB
        IERC20(token).approve(address(router), balance);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(balance, 0, path, address(this), block.timestamp + 300);

        if (address(this).balance > 0) {
            // fraction out bnb received
            uint part1 = address(this).balance * burnFundPercentage / 100;
            uint part2 = address(this).balance - part1;

            // send to destinations
            _send(burnFund, part1);
            _send(NFTAddr, part2);
        }
    }

    function setBurnFund(address tFund) external onlyOwner {
        require(tFund != address(0));
        burnFund = tFund;
    }
    function setNFTAddr(address NFTAddr_) external onlyOwner {
        require(NFTAddr_ != address(0));
        NFTAddr = NFTAddr_;
    }
    function setApproved(address caller, bool isApproved) external onlyOwner {
        approved[caller] = isApproved;
        emit Approved(caller, isApproved);
    }
    function setMinTriggerAmount(uint256 minTriggerAmount) external onlyOwner {
        minimumTokensRequiredToTrigger = minTriggerAmount;
    }
    function setBurnFundPercentage(uint256 newAllocatiton) external onlyOwner {
        burnFundPercentage = newAllocatiton;
    }
    function setBurnPercentage(uint256 newAllocatiton) external onlyOwner {
        burnPercentage = newAllocatiton;
    }
    function withdraw() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }
    
    function withdraw(address _token) external onlyOwner {
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }
    receive() external payable {}
    function _send(address recipient, uint amount) internal {
        (bool s,) = payable(recipient).call{value: amount}("");
        require(s);
    }
}