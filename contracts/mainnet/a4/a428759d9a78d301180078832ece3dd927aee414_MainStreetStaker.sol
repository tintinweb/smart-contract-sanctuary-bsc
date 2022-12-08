/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;

        _status = _NOT_ENTERED;
    }
}

interface IBananaPool {
    function enterStaking(uint256 _amount) external;
    function leaveStaking(uint256 _amount) external;
}

interface IGnanaPool {
    function deposit(uint256 _amount) external;
    function withdraw(uint256 _amount) external;
}

interface IApeSwapRouter {
    function getAmountsOut(uint amountIn, address[] memory path) external returns (uint[] memory amounts);
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint[] memory amounts);
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint[] memory amounts);
}

interface IApeSwapTreasury {
    function buy(uint _amount) external;
}

interface IMinter {
    function balanceOf(address owner) external returns (uint256);
    function ownerOf(uint256 tokenId) external returns (address);
    function totalSupply() external returns (uint256);
}

interface IDistributor {
    function createDistributionCycle(uint amount) external;
}

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract MainStreetStaker is Ownable, ReentrancyGuard {
    // using SafeMath for uint256;
    uint256 MAX_INT = 2**256 - 1;

    // informative variables
    uint public TOTAL_BNB_RECEIVED = 0;
    uint public TOTAL_BANANA_BOUGHT = 0;
    uint public TOTAL_BANANA_STAKED = 0;
    uint public TOTAL_GNANA_BOUGHT = 0;
    uint public TOTAL_GNANA_STAKED = 0;
    uint public TOTAL_MAINST_BURNED = 0;
    uint public TOTAL_BANANA_DISTRIBUTED = 0;

    // for governance and time lock
    bool isBananaApproved = false;
    bool isGnanaApproved = false;

    uint256 public DISTRIBUTION_PERCENTAGE = 50; // between banana/gnana pools

    address public BANANA_POOL = 0x5c8D727b265DBAfaba67E050f2f739cAeEB4A6F9; 
    address public GNANA_POOL = 0x8F97B2E6559084CFaBA140e2AB4Da9aAF23FE7F8;
    address public APESWAP_ROUTER = 0xcF0feBd3f17CEf5b47b0cD257aCf6025c5BFf3b7; 
    address public MINTER = 0xa36c806c13851F8B27780753563fdDAA6566f996; 
    address public DISTRIBUTOR = 0x571Db7CB1376B28FACa0F19A05F7d7781E97771f;
    address public BOUNTY = 0xA97F7EB14da5568153Ea06b2656ccF7c338d942f;
    address public WRAPPED_BNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public BANANA_TOKEN = 0x603c7f932ED1fc6575303D8Fb018fDCBb0f39a95;
    address public GNANA_TOKEN = 0xdDb3Bd8645775F59496c821E4F55A7eA6A6dc299;
    address public APESWAP_TREASURY = 0xec4b9d1fd8A3534E31fcE1636c7479BcD29213aE;
    address payable public ETERNALLABS_TREASURY = payable(0xA97F7EB14da5568153Ea06b2656ccF7c338d942f);
    address payable public FUNDING_WALLET = payable(0xA97F7EB14da5568153Ea06b2656ccF7c338d942f);
    address public MAINST_TOKEN = 0x8FC1A944c149762B6b578A06c0de2ABd6b7d2B89;

    uint public TIME_LOCKED_BANANA = 0;
    bool timeLockBananaActivated = false;

    uint public TIME_LOCKED_GNANA = 0;
    bool timeLockGananaActivated = false;

    uint public FUNDING_WALLET_PERCENTAGE = 2;
    uint public ETERNALLABS_PERCENTAGE = 5;
    uint public BOUNTY_PERCENTAGE = 20;
    uint public BANANA_REINVEST_PERCENTAGE = 5;
    uint public GNANA_REINVEST_PERCENTAGE = 0;
    uint public MAINST_BURN_PERCENTAGE = 2;

    constructor() {}

    function setBananaReinvestPercentage(uint _percent) public onlyOwner() {
        BANANA_REINVEST_PERCENTAGE = _percent;
    }

    function setGnanaReinvestPercentage(uint _percent) public onlyOwner() {
        GNANA_REINVEST_PERCENTAGE = _percent;
    }

    function setMainstBurnPercentage(uint _percent) public onlyOwner() {
        MAINST_BURN_PERCENTAGE = _percent;
    }

    function setFundingWallet(address payable _address) public onlyOwner() {
        FUNDING_WALLET = _address;
    }

    function setEternalLabsTreasury(address payable _address) public onlyOwner() {
        ETERNALLABS_TREASURY = _address;
    }

    function setMinterAddress(address minter) public onlyOwner {
        MINTER = minter;
    }

    function setDistributorAddress(address distributor) public onlyOwner {
        DISTRIBUTOR = distributor;
    }

    function setBountyAddress(address bounty) public onlyOwner {
        BOUNTY = bounty;
    }

    function setFundingWalletPercentage(uint _percent) public onlyOwner {
        FUNDING_WALLET_PERCENTAGE = _percent;
    }

    function activateTimeLockBanana() public onlyOwner() {
        require(!timeLockBananaActivated, "Timelock already activated");
        require(TIME_LOCKED_BANANA == 0, "Time not reset yet");
        TIME_LOCKED_BANANA = block.timestamp;
        timeLockBananaActivated = true;
    }

    function activateTimeLockGanana() public onlyOwner() {
        require(!timeLockGananaActivated, "Timelock already activated");
        require(TIME_LOCKED_GNANA == 0, "Time not reset yet");
        TIME_LOCKED_GNANA = block.timestamp;
        timeLockGananaActivated = true;
    }

    function changeBananaPoolAddress(address newBananaPoolAddress) public onlyOwner() {
        require(timeLockBananaActivated, "Time lock not activated yet");
        require((TIME_LOCKED_BANANA + 172800) < block.timestamp, "time lock still in process");
        BANANA_POOL = newBananaPoolAddress;
        timeLockBananaActivated = false;
        TIME_LOCKED_BANANA = 0;
    }


    function changeGananaPoolAddress(address newGananaPoolAddress) public onlyOwner() {
        require(timeLockGananaActivated, "Time lock not activated yet");
        require((TIME_LOCKED_GNANA + 172800) < block.timestamp, "time lock still in process");
        GNANA_POOL = newGananaPoolAddress;
        timeLockGananaActivated = false;
        TIME_LOCKED_GNANA = 0;
    }

    // distribution percentage between BANANA and GNANA pools
    function setDistributionPercentage(uint percentage) public onlyOwner() {
        require(percentage > 0 && percentage <= 100, "percentage should be between 1-100");
        DISTRIBUTION_PERCENTAGE = percentage;
    }

    function calculateBananaDistribution(uint bananaAmount) public view returns(uint[] memory _amounts) {
        uint forBananaPool = (bananaAmount / 100) * DISTRIBUTION_PERCENTAGE;
        uint forGananaPool = bananaAmount - forBananaPool;
        uint[] memory amounts = new uint[](2);
        amounts[0] = forBananaPool;
        amounts[1] = forGananaPool;
        return amounts;
    }

    function buyBanana(uint forBNBAmount) private returns(uint boughtBananaAmount) {
        address[] memory path = new address[](2);
        path[0] = WRAPPED_BNB;
        path[1] = BANANA_TOKEN;
        uint[] memory bananaAmountsOut = IApeSwapRouter(APESWAP_ROUTER).getAmountsOut(forBNBAmount, path);
        uint[] memory amounts = IApeSwapRouter(APESWAP_ROUTER).swapExactETHForTokens{value : forBNBAmount}(
            bananaAmountsOut[1],
            path,
            address(this),
            block.timestamp + 100
        );
        return amounts[1];
    }

    function buyGanana(uint forBananaAmount) private returns(uint boughtGnanaAmount) {
        IApeSwapTreasury(APESWAP_TREASURY).buy(forBananaAmount);
        return IBEP20(GNANA_TOKEN).balanceOf(address(this));
    }

    function stakeBanana(uint bananaToStake) private returns (uint stakedBananaAmount) {
        IBananaPool(BANANA_POOL).enterStaking(bananaToStake);
        return bananaToStake;
    }

    // stake remaining banana if there is any or if contract is redeployed
    function stakeRemainingBanana() public onlyOwner() {
        uint remainingBanana = IBEP20(BANANA_TOKEN).balanceOf(address(this));
        IBananaPool(BANANA_POOL).enterStaking(remainingBanana);
        TOTAL_BANANA_STAKED += remainingBanana;
    }

    // stake remaining ganana if any or if contract is redeployed
    function stakeRemainingGnana() public onlyOwner() {
        uint gnanaToStake = IBEP20(GNANA_TOKEN).balanceOf(address(this));
        IGnanaPool(GNANA_POOL).deposit(gnanaToStake);
        TOTAL_GNANA_STAKED += gnanaToStake;
    }

    function harvestBanana() private returns (uint harvestedAmount) {
        uint balanceBefore = IBEP20(BANANA_TOKEN).balanceOf(address(this));
        IBananaPool(BANANA_POOL).leaveStaking(0);
        uint balanceAfter = IBEP20(BANANA_TOKEN).balanceOf(address(this));
        return balanceAfter - balanceBefore;
    }

    // uint _percent is for the percentage of banana staked, returns unstaked + harvested banana + leftover banana from gnana withdraw
    function withdrawBanana(uint percent) public onlyOwner() {
        require(percent > 0 && percent <= 100, "incorrect percentage");
        IBananaPool(BANANA_POOL).leaveStaking((TOTAL_BANANA_STAKED / 100) *  percent);
        IBEP20(BANANA_TOKEN).transfer(msg.sender, IBEP20(BANANA_TOKEN).balanceOf(address(this)));
    }

    function withdrawLeftOverBanana() public onlyOwner() {
        IBEP20(BANANA_TOKEN).transfer(msg.sender, IBEP20(BANANA_TOKEN).balanceOf(address(this)));
    }

    function stakeGanana() private returns (uint stakedGananaAmount) {
        uint gnanaToStake = IBEP20(GNANA_TOKEN).balanceOf(address(this));
        IGnanaPool(GNANA_POOL).deposit(gnanaToStake);
        return gnanaToStake;
    }

    function harvestGnana() private returns(uint harvestedAmount) {
        uint balanceBefore = IBEP20(GNANA_TOKEN).balanceOf(address(this));
        IGnanaPool(GNANA_POOL).withdraw(0);
        uint balanceAfter = IBEP20(GNANA_TOKEN).balanceOf(address(this));
        return balanceAfter - balanceBefore;
    }

    function withdrawGnana(uint _amount) public onlyOwner() {
        IGnanaPool(GNANA_POOL).withdraw(_amount);
        IBEP20(GNANA_TOKEN).transfer(msg.sender, IBEP20(GNANA_TOKEN).balanceOf(address(this)));
    }

    function withdrawLeftOverGnana() public onlyOwner() {
        IBEP20(GNANA_TOKEN).transfer(msg.sender, IBEP20(GNANA_TOKEN).balanceOf(address(this)));
    }

    function deposit() external payable nonReentrant() {
        require(isBananaApproved, "Banana not approved yet");
        require(isGnanaApproved, "Gnana not approved yet");
        TOTAL_BNB_RECEIVED += msg.value;
        uint bananaBought = buyBanana(msg.value);
        TOTAL_BANANA_BOUGHT += bananaBought;
        uint[] memory bananaDistribution = calculateBananaDistribution(bananaBought);
        TOTAL_BANANA_STAKED += stakeBanana(bananaDistribution[0]);
        uint gnanaBought = buyGanana(bananaDistribution[1]);
        TOTAL_GNANA_BOUGHT += gnanaBought;
        TOTAL_GNANA_STAKED += stakeGanana();
    }

    function compound() public nonReentrant() {
        require(msg.sender == BOUNTY || msg.sender == owner(), "MM: not bounty");
        harvestBanana();
        harvestGnana();
        // ganana pool rewards banana so its the total rewards.
        uint totalBananaBalance = IBEP20(BANANA_TOKEN).balanceOf(address(this));
        if (BANANA_REINVEST_PERCENTAGE > 0) {
            uint bananaToReInvest = (totalBananaBalance / 100) * BANANA_REINVEST_PERCENTAGE; 
            TOTAL_BANANA_STAKED += stakeBanana(bananaToReInvest);
        }
        if (GNANA_REINVEST_PERCENTAGE > 0) {
            uint bananaForGnana = (totalBananaBalance / 100) * GNANA_REINVEST_PERCENTAGE; 
            TOTAL_GNANA_BOUGHT += buyGanana(bananaForGnana);
            TOTAL_GNANA_STAKED += stakeGanana();
        }
        uint bananaForFund = (totalBananaBalance / 100) * FUNDING_WALLET_PERCENTAGE; 
        uint bananaForEternalLabs = (totalBananaBalance / 100) * ETERNALLABS_PERCENTAGE;
        uint bananaForBounty = (totalBananaBalance / 100) * BOUNTY_PERCENTAGE;
        IBEP20(BANANA_TOKEN).transfer(BOUNTY, bananaForBounty);
        IBEP20(BANANA_TOKEN).transfer(FUNDING_WALLET, bananaForFund);
        IBEP20(BANANA_TOKEN).transfer(ETERNALLABS_TREASURY, bananaForEternalLabs);
        uint mainst = buyBackMainstreet(IBEP20(BANANA_TOKEN).balanceOf(address(this)));
        if (MAINST_BURN_PERCENTAGE > 0) {
            uint burned = burnMainst((mainst / 100) * MAINST_BURN_PERCENTAGE);
            TOTAL_MAINST_BURNED += burned;
            mainst = mainst - burned;
        }
        IBEP20(MAINST_TOKEN).transfer(DISTRIBUTOR, mainst);
        IDistributor(DISTRIBUTOR).createDistributionCycle(mainst);
    }

    function fundWallet(uint bananaAmount) private returns(uint boughtBNB){
        address[] memory path = new address[](2);
        path[0] = BANANA_TOKEN;
        path[1] = WRAPPED_BNB;
        uint[] memory bnbAmountsOut = IApeSwapRouter(APESWAP_ROUTER).getAmountsOut(bananaAmount, path);
        uint[] memory amounts = IApeSwapRouter(APESWAP_ROUTER).swapExactTokensForETH(
            bananaAmount,
            bnbAmountsOut[1],
            path,
            msg.sender,
            block.timestamp + 100
        );
        return amounts[1];
    }

    function buyBackMainstreet(uint bananaAmount) private returns(uint mainstPurchased) {
        address[] memory path = new address[](3);
        path[0] = BANANA_TOKEN;
        path[1] = WRAPPED_BNB;
        path[2] = MAINST_TOKEN;
        uint[] memory mainstAmountsOut = IApeSwapRouter(APESWAP_ROUTER).getAmountsOut(bananaAmount, path);
        uint slippage = (mainstAmountsOut[2] / 100) * 12;
        uint[] memory amounts = IApeSwapRouter(APESWAP_ROUTER).swapExactTokensForTokens(
            bananaAmount,
            mainstAmountsOut[2] - slippage,
            path,
            address(this),
            block.timestamp + 100
        );
        return amounts[1];
    }

    function burnMainst(uint amount) private returns(uint){
        IBEP20(MAINST_TOKEN).transfer(0x000000000000000000000000000000000000dEaD, amount);
        return amount;
    }

    function withdrawRemainingMainstreet() public onlyOwner() {
        IBEP20(MAINST_TOKEN).transfer(msg.sender, IBEP20(MAINST_TOKEN).balanceOf(address(this)));
    }

    function getBananaApproved() public onlyOwner() {
        require(!isBananaApproved, "Already approved");
        IBEP20(BANANA_TOKEN).approve(BANANA_POOL, MAX_INT);
        IBEP20(BANANA_TOKEN).approve(APESWAP_ROUTER, MAX_INT);
        isBananaApproved = true;
    }

    function getGnanaApproved() public onlyOwner() {
        require(!isGnanaApproved, "Already approved");
        IBEP20(GNANA_TOKEN).approve(GNANA_POOL, MAX_INT);
        IBEP20(BANANA_TOKEN).approve(APESWAP_TREASURY, MAX_INT); // to buy gnana
        isGnanaApproved = true;
    }

    fallback() external payable { }
    
    receive() external payable { }
}