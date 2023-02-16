/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

pragma solidity ^0.8;

interface IERC20 {
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
    function approve(address, uint) external returns (bool);
}

interface IFilterRouter {
    function addLiquidityETH(address, uint, uint, uint, address, uint, uint) external payable returns (uint, uint, uint);
}

contract SieveLauncher {
    uint presaleStatus; // 0 = not started, 1 = started, 2 = ended, 3 = finalized

    address owner;

    mapping(address => uint) public userTokensBought;

    // **** PRESALE CONFIG ****

    address routerAddress = 0x32bC0A0ade33DD7538B75D6eC6e5FBA94a97d35F;
    address sieveToken = 0x7Fe0009f87dbbeEd661ED573CE4909D937c53e72;
    

    uint softCap = 0.04 ether;
    uint hardCap = 0.5 ether; // BNB hardcap
    uint totalTokens = 1000000e18; //1 million
    uint percentageToLiquidity = 30;
    uint percentageToOwners = 10;
    uint tokenBuyLimit = 20000e18;
    uint presaleRunTime = 1800;//30 days;

    // **** END OF CONFIG ****

    uint tokensPerBNB = totalTokens / ((hardCap * (100 - percentageToLiquidity)) / 100);
    uint presaleEndTime;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "SieveLauncher: OWNER_ONLY");
        _;
    }

    // **** OWNER ONLY FUNCTIONS ****

    function startPresale() public onlyOwner {     
        require(presaleStatus == 0, "SieveLauncher: ALREADY_STARTED");
        IERC20(sieveToken).transferFrom(msg.sender, address(this), totalTokens);
        presaleStatus = 1;
        presaleEndTime = block.timestamp + presaleRunTime;
    }

    function finalizePresale() public onlyOwner {
        require(presaleStatus == 2);
        presaleStatus = 3;

        IERC20(sieveToken).approve(routerAddress, totalTokens);
        IFilterRouter(routerAddress).addLiquidityETH{value: address(this).balance}(sieveToken, totalTokens, 0, 0, 0x0000000000000000000000000000000000000000, block.timestamp, type(uint).max);
    }

    // **** USER FUNCTIONS ****

    function buyTokens() public payable {
        require(presaleStatus == 1, "SieveLauncher: CANNOT_BUY");
        userTokensBought[msg.sender] += (tokensPerBNB * msg.value) / 10e18;

        require(userTokensBought[msg.sender] <= tokenBuyLimit, "SieveLauncher: BUY_LIMIT_REACHED");

        if (address(this).balance >= hardCap) presaleStatus = 2;
        if (presaleEndTime >= block.timestamp) presaleStatus = 2;
    }

    function claimTokens() public {
        require(presaleStatus == 3, "SieveLauncher: PRESALE_NOT_ENDED");
        IERC20(sieveToken).transfer(msg.sender, userTokensBought[msg.sender]);
        userTokensBought[msg.sender] == 0; //reset to 0
    }

    function claimRefund() public {
        require(presaleStatus == 2, "SieveLauncher: CANNOT_CLAIM");
        payable(msg.sender).transfer((userTokensBought[msg.sender] / tokensPerBNB) * 10e18);
    }

    // **** MISC ****

    receive() external payable {
        buyTokens();
    }
}