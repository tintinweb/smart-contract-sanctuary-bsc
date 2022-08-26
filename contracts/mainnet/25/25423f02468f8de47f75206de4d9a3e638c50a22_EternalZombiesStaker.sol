/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: MIT
/**
 * @title EternalZombiesStaker
 * @author : saad sarwar
 */

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

library Percentages {
    // Get value of a percent of a number
    function calcPortionFromBasisPoints(uint _amount, uint _basisPoints) public pure returns(uint) {
        if(_basisPoints == 0 || _amount == 0) {
            return 0;
        } else {
            uint _portion = _amount * _basisPoints / 10000;
            return _portion;
        }
    }

    // Get basis points (percentage) of _portion relative to _amount
    function calcBasisPoints(uint _amount, uint  _portion) public pure returns(uint) {
        if(_portion == 0 || _amount == 0) {
            return 0;
        } else {
            uint _basisPoints = (_portion * 10000) / _amount;
            return _basisPoints;
        }
    }
}

interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external returns (address);
    function TOKEN_ID() external view returns (uint);
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

interface IPancakeSwapRouter {
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
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IDrFrankenstein {
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 tokenWithdrawalDate;
        uint256 rugDeposited;
        bool paidUnlockFee;
        uint256  nftRevivalDate;
    }
    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
    function userInfo(uint, address) external returns(UserInfo memory);
}

interface ITombOverlay {
    function mintingFeeInBnb() external view returns(uint);
    function startMinting(uint _pid) external payable returns (bytes32);
    function finishMinting(uint _pid) external returns (uint, uint);
}

interface IDistributor {
    function createDistributionCycle(uint amount) external;
}

interface IRandomNumGenerator {
    function requestRandomNumber() external returns(bytes32 requestId);
    function result(bytes32) external returns(uint256);
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract EternalZombiesStaker is Ownable, ReentrancyGuard, IERC721Receiver {

    using Percentages for uint;

    uint256 MAX_INT = 2**256 - 1;

    uint public BNB_RECEIVED;
    uint public ZMBE_BOUGHT;
    uint public LP_BOUGHT;
    uint public COMPOUNDED;
    uint public ZMBE_DISTRIBUTED;

    address public ZMBE;
    address public WRAPPED_BNB;
    address public PANCAKE_ROUTER;
    address public MINTER;
    address public DISTRIBUTOR;
    address public RANDOM_NUMBER_GENERATOR;
    address public DR_FRANKENSTEIN;
    address public PANCAKE_LP_TOKEN;
    address public TOMB_OVERLAY;
    address public WINNER;

    uint public RESTAKE_PERCENTAGE;
    uint public FUNDING_WALLET_PERCENTAGE;
    uint public BURN_PERCENTAGE;

    uint public POOL_ID = 11;

    uint public REWARD_TOKEN_ID;
    uint public REWARD_TOKEN_RARITY;
    uint public TOTAL_NFTS_DISTRIBUTED;

    bytes32 public requestId;

    constructor(
        address wBNB,
        address zmbe,
        address router,
        address minter,
        address distributor,
        address randomNumberGenerator,
        address drFrankenstein,
        address lp_tokens,
        address tombOverlay,
        uint restakePercentage,
        uint fundingWalletPercentage,
        uint burnPercentage
    ) {
        WRAPPED_BNB = wBNB;
        ZMBE = zmbe;
        PANCAKE_ROUTER = router;
        MINTER = minter;
        DISTRIBUTOR = distributor;
        RANDOM_NUMBER_GENERATOR = randomNumberGenerator;
        DR_FRANKENSTEIN = drFrankenstein;
        PANCAKE_LP_TOKEN = lp_tokens;
        TOMB_OVERLAY = tombOverlay;
        RESTAKE_PERCENTAGE = restakePercentage;
        FUNDING_WALLET_PERCENTAGE = fundingWalletPercentage;
        BURN_PERCENTAGE = burnPercentage;
    }

    function setMinterAddress(address minter) public onlyOwner {
        MINTER = minter;
    }

    function setDistributor(address distributor) public onlyOwner() {
        DISTRIBUTOR = distributor;
    }

    function setDrFrankenstein(address frankenstein) public onlyOwner() {
        DR_FRANKENSTEIN = frankenstein;
    }

    function setPancakeLP(address lp_token) public onlyOwner() {
        PANCAKE_LP_TOKEN = lp_token;
    }

    function setPancakeRouter(address router) public onlyOwner() {
        PANCAKE_ROUTER = router;
    }

    function setTombOverlay(address tombOverlay) public onlyOwner() {
        TOMB_OVERLAY = tombOverlay;
    }

    function setRandomNumGenerator(address generator) public onlyOwner() {
        RANDOM_NUMBER_GENERATOR = generator;
    }

    function adjustRestakePercentage(uint percentage) public onlyOwner() {
        RESTAKE_PERCENTAGE = percentage;
    }

    function adjustFundingWalletPercentage(uint percentage) public onlyOwner() {
        FUNDING_WALLET_PERCENTAGE = percentage;
    }

    function adjustBurnPercentage(uint percentage) public onlyOwner() {
        BURN_PERCENTAGE = percentage;
    }

    function setPoolId(uint poolId) public onlyOwner() {
        POOL_ID = poolId;
    }

    function buyZMBE(uint bnbAmount) private returns(uint boughtAmount) {
        address[] memory path = new address[](2);
        path[0] = WRAPPED_BNB;
        path[1] = ZMBE;
        uint[] memory amountsOut = IPancakeSwapRouter(PANCAKE_ROUTER).getAmountsOut(bnbAmount, path);
        uint[] memory amounts = IPancakeSwapRouter(PANCAKE_ROUTER).swapExactETHForTokens{value : bnbAmount}(
            amountsOut[1],
            path,
            address(this),
            block.timestamp
        );
        return amounts[1];
    }

    function buyLPTokens(uint bnb) private returns(uint LpBought){
        address[] memory path = new address[](2);
        path[0] = WRAPPED_BNB;
        path[1] = ZMBE;
        uint[] memory amountsOut = IPancakeSwapRouter(PANCAKE_ROUTER).getAmountsOut(bnb, path);
        ( , , uint liquidity) = IPancakeSwapRouter(PANCAKE_ROUTER).addLiquidityETH{value: bnb}(
            ZMBE,
            amountsOut[1],
            amountsOut[1].calcPortionFromBasisPoints(9500),
            bnb.calcPortionFromBasisPoints(9500),
            address(this),
            block.timestamp
        );
        return liquidity;
    }

    function deposit() external payable nonReentrant() returns(bool success){
        BNB_RECEIVED += msg.value;
        uint zmbe_bought = buyZMBE((msg.value / 2));
        ZMBE_BOUGHT += zmbe_bought;
        uint lpBought = buyLPTokens((msg.value / 2));
        LP_BOUGHT += lpBought;
        stake(lpBought);
        return(true);
    }

    function stake(uint amount) private {
        IDrFrankenstein(DR_FRANKENSTEIN).deposit(POOL_ID, amount);
    }

    function restake(uint zmbeAmount) private {
        uint zmbeForBnb = zmbeAmount / 2;
        uint bnbBought = buyBnb(zmbeForBnb);
        uint lpBought = buyLPTokens(bnbBought);
        LP_BOUGHT += lpBought;
        stake(lpBought);
    }

    function harvest() private {
        IDrFrankenstein(DR_FRANKENSTEIN).withdraw(POOL_ID, 0);
    }

    function compoundAndDistribute() public {
        require(msg.sender == owner() || msg.sender == DISTRIBUTOR, "EZ: not owner or ditributor");
        harvest();
        uint balance = IBEP20(ZMBE).balanceOf(address(this));
        uint forDev = (balance / 100) * FUNDING_WALLET_PERCENTAGE;
        uint forRestake = (balance / 100) * RESTAKE_PERCENTAGE;
        uint forBurn = (balance / 100) * BURN_PERCENTAGE;
        uint forDistribution = balance - (forDev + forRestake + forBurn);
        restake(forRestake);
        IBEP20(ZMBE).transfer(0x000000000000000000000000000000000000dEaD, forBurn);
        IBEP20(ZMBE).transfer(msg.sender, forDev);
        IBEP20(ZMBE).transfer(DISTRIBUTOR, forDistribution);
        ZMBE_DISTRIBUTED += forDistribution;
        IDistributor(DISTRIBUTOR).createDistributionCycle(forDistribution);
    }

    function buyBnb(uint zmbe) private returns(uint boughtBNB){
        address[] memory path = new address[](2);
        path[0] = ZMBE;
        path[1] = WRAPPED_BNB;
        uint[] memory bnbAmountsOut = IPancakeSwapRouter(PANCAKE_ROUTER).getAmountsOut(zmbe, path);
        uint[] memory amounts = IPancakeSwapRouter(PANCAKE_ROUTER).swapExactTokensForETH(
            zmbe,
            bnbAmountsOut[1],
            path,
            address(this),
            block.timestamp
        );
        return amounts[1];
    }

    function sendRemainingTokensToDistributor() public onlyOwner() {
        IBEP20(ZMBE).transfer(DISTRIBUTOR, IBEP20(ZMBE).balanceOf(address(this)));
    }

    function withdrawRemainingBnb() public onlyOwner() {
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawRemainingZmbe() public onlyOwner() {
        IBEP20(ZMBE).transfer(msg.sender, IBEP20(ZMBE).balanceOf(address(this)));
    }

    function withdrawRewardedNft(address tokenAddress, uint tokenId) public onlyOwner() {
        IERC721(tokenAddress).transferFrom(address(this), msg.sender, tokenId);
    }

    function withdrawLpTokens(uint amount) public onlyOwner() {
        IBEP20(PANCAKE_LP_TOKEN).transfer(msg.sender, amount);
    }

    function withdrawLpTokensFromPool(uint amount) public onlyOwner() {
        IDrFrankenstein(DR_FRANKENSTEIN).withdraw(POOL_ID, amount);
    }

    function getZMBEApproved() public onlyOwner() {
        IBEP20(ZMBE).approve(PANCAKE_ROUTER, MAX_INT);
    }

    function getLPApproved() public onlyOwner() {
        IBEP20(PANCAKE_LP_TOKEN).approve(DR_FRANKENSTEIN, MAX_INT);
    }

    function startMinting() public onlyOwner() {
        uint bnbValue = ITombOverlay(TOMB_OVERLAY).mintingFeeInBnb();
        ITombOverlay(TOMB_OVERLAY).startMinting{value: bnbValue}(POOL_ID);
    }

    function claimNft() public onlyOwner() {
        (uint rarity, uint tokenId) = ITombOverlay(TOMB_OVERLAY).finishMinting(POOL_ID);
        REWARD_TOKEN_ID = tokenId;
        REWARD_TOKEN_RARITY = rarity;
        requestId = IRandomNumGenerator(RANDOM_NUMBER_GENERATOR).requestRandomNumber();
    }

    function sendRewardedNft(address tokenAddress) public onlyOwner() {
        uint randomNumber = IRandomNumGenerator(RANDOM_NUMBER_GENERATOR).result(requestId);
        require(randomNumber != 0, "EZ: random number not set");
        // if token id is perfectly divisible by the random number then the remainder will be zero which is not a valid token id
        if ((randomNumber % (IERC721(MINTER).TOKEN_ID())) != 0) {
            WINNER = IERC721(MINTER).ownerOf(randomNumber % (IERC721(MINTER).TOKEN_ID()));
        } else {
            WINNER = IERC721(MINTER).ownerOf(1);
        }
        IERC721(tokenAddress).transferFrom(address(this), WINNER, REWARD_TOKEN_ID);
        TOTAL_NFTS_DISTRIBUTED += 1;
    }

    fallback() external payable {}

    receive() external payable {}

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}