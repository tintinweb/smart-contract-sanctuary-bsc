/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: None

/**
 * @title EternalLabsStaker
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

interface IRouter {
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

interface ICakePool {
    function deposit(uint256 _amount, uint256 _lockDuration) external;
    function withdrawByAmount(uint256 _amount) external;
    function withdraw(uint256 _shares) external;
    function withdrawAll() external;
}

interface IMasterChef {
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 boostMultiplier;
    }
    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
    function pendingCake(uint256 _pid, address _user) external returns(uint);
    function userInfo(uint, address) external returns(UserInfo memory);
}

interface IFarmBoosterProxyFactory {
    function createFarmBoosterProxy() external;
    function proxyContract(address) external returns(address);
    function proxyUser(address) external returns(address);
}

interface IFarmBoosterProxy {
    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
    function emergencyWithdraw(uint256 _pid) external;
}

interface IFarmBooster {
    function activate(uint256 _pid) external;
}

contract EternalCakesStaker is Ownable, ReentrancyGuard, IERC721Receiver {

    using Percentages for uint;

    uint256 MAX_INT = 2**256 - 1;

    uint public BNB_RECEIVED;
    uint public TOKEN_BOUGHT;
    uint public LP_BOUGHT;
    uint public COMPOUNDED;
    uint public TOKEN_DISTRIBUTED;

    address public TOKEN = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
    address public WRAPPED_BNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public MASTERCHEF = 0xa5f8C5Dbd5F286960b9d90548680aE5ebFf07652;
    address public POOL = 0x45c54210128a065de780C4B0Df3d16664f7f859e;
    address public FARM_BOOSTER = 0xE4FAa3Ef5A9708C894435B0F39c2B440936A3A52;
    address public FARM_BOOSTER_PROXY; // added after creation
    address public FARM_BOOSTER_PROXY_FACTORY = 0x2C36221bF724c60E9FEE3dd44e2da8017a8EF3BA;
    address public MINTER;
    address public DISTRIBUTOR = 0x453b2d84d9A9520a91f8Ee4C0B7DcBEB0BB58e23; // mock distributor for testing, will be changed later
    address public BOUNTY = 0x453b2d84d9A9520a91f8Ee4C0B7DcBEB0BB58e23; // mock bounty for testing, will be changed later
    address public LP_TOKEN = 0x0eD7e52944161450477ee417DE9Cd3a859b14fD0;
    address public DEV = 0xA97F7EB14da5568153Ea06b2656ccF7c338d942f;

    uint public RESTAKE_PERCENTAGE = 2000; // 20 % initially to compound faster
    uint public BOOSTER_PERCENTAGE = 300; // 3% for cake booster pool
    uint public DEV_PERCENTAGE = 200; // 2% for dev
    uint public SLIPPAGE = 9500; // 95 % SO, 5 % slippage just to remain on the safe side

    uint public POOL_ID = 2; // masterchefv2 pool id for CAKE-BNB LP pool
    uint public BOOSTER_DURATION = 360 days;

    bool public FUND_BOOSTER = false;

    constructor() {}

    function flipFundBooster() public onlyOwner() {
        FUND_BOOSTER = !FUND_BOOSTER;
    }

    function setToken(address token) public onlyOwner() {
        TOKEN = token;
    }

    function setMinterAddress(address minter) public onlyOwner() {
        MINTER = minter;
    }

    function setDistributor(address distributor) public onlyOwner() {
        DISTRIBUTOR = distributor;
    }

    function setBounty(address bounty) public onlyOwner() {
        BOUNTY = bounty;
    }

    function setDev(address dev) public onlyOwner() {
        DEV = dev;
    }

    function setMasterchef(address masterchef) public onlyOwner() {
        MASTERCHEF = masterchef;
    }

    function setLPToken(address lp_token) public onlyOwner() {
        LP_TOKEN = lp_token;
    }

    function setRouter(address router) public onlyOwner() {
        ROUTER = router;
    }

    function adjustRestakePercentage(uint percentage) public onlyOwner() {
        RESTAKE_PERCENTAGE = percentage;
    }

    function adjustDevPercentage(uint percentage) public onlyOwner() {
        DEV_PERCENTAGE = percentage;
    }

    function adjustBoosterPercentage(uint percentage) public onlyOwner() {
        BOOSTER_PERCENTAGE = percentage;
    }

    function adjustSlippagePercentage(uint percentage) public onlyOwner() {
        SLIPPAGE = percentage;
    }

    function setPoolId(uint poolId) public onlyOwner() {
        POOL_ID = poolId;
    }

    function setBoosterDuration(uint duration) public onlyOwner() {
        BOOSTER_DURATION = duration;
    }

    function buyToken(uint bnbAmount) private returns(uint boughtAmount) {
        address[] memory path = new address[](2);
        path[0] = WRAPPED_BNB;
        path[1] = TOKEN;
        uint[] memory amountsOut = IRouter(ROUTER).getAmountsOut(bnbAmount, path);
        uint[] memory amounts = IRouter(ROUTER).swapExactETHForTokens{value : bnbAmount}(
            amountsOut[1],
            path,
            address(this),
            block.timestamp
        );
        return amounts[1];
    }

    function buyBnb(uint tokenAmount) private returns(uint boughtBNB){
        address[] memory path = new address[](2);
        path[0] = TOKEN;
        path[1] = WRAPPED_BNB;
        uint[] memory bnbAmountsOut = IRouter(ROUTER).getAmountsOut(tokenAmount, path);
        uint[] memory amounts = IRouter(ROUTER).swapExactTokensForETH(
            tokenAmount,
            bnbAmountsOut[1],
            path,
            address(this),
            block.timestamp
        );
        return amounts[1];
    }

    function buyLPTokens(uint bnb) private returns(uint LpBought){
        address[] memory path = new address[](2);
        path[0] = WRAPPED_BNB;
        path[1] = TOKEN;
        uint[] memory amountsOut = IRouter(ROUTER).getAmountsOut(bnb, path);
        ( , , uint liquidity) = IRouter(ROUTER).addLiquidityETH{value: bnb}(
            TOKEN,
            amountsOut[1],
            amountsOut[1].calcPortionFromBasisPoints(SLIPPAGE),
            bnb.calcPortionFromBasisPoints(SLIPPAGE),
            address(this),
            block.timestamp
        );
        return liquidity;
    }

    function stakeInMasterChef(uint amount) private {
        IMasterChef(MASTERCHEF).deposit(POOL_ID, amount);
    }
    // first deposit to normal CAKE-BNB pool
    function firstDeposit() external payable onlyOwner() returns(bool success){
        BNB_RECEIVED += msg.value;
        uint token_bought = buyToken((msg.value / 2));
        TOKEN_BOUGHT += token_bought;
        uint lpBought = buyLPTokens((msg.value / 2));
        LP_BOUGHT += lpBought;
        stakeInMasterChef(lpBought);
        return(true);
    }

    function stakeInBooster(uint amount) private {
        IFarmBoosterProxy(FARM_BOOSTER_PROXY).deposit(POOL_ID, amount);
    }

    function restake(uint tokenAmount) private {
        uint tokenForBnb = tokenAmount / 2;
        uint bnbBought = buyBnb(tokenForBnb);
        uint lpBought = buyLPTokens(bnbBought);
        LP_BOUGHT += lpBought;
        stakeInBooster(lpBought);
    }

    // deposit to boosted CAKE-BNB pool
    function deposit() external payable nonReentrant() returns(bool success){
        BNB_RECEIVED += msg.value;
        uint token_bought = buyToken((msg.value / 2));
        TOKEN_BOUGHT += token_bought;
        uint lpBought = buyLPTokens((msg.value / 2));
        LP_BOUGHT += lpBought;
        stakeInBooster(lpBought);
        return(true);
    }

    function harvest() private {
        IFarmBoosterProxy(FARM_BOOSTER_PROXY).deposit(POOL_ID, 0);
    }

    function compound() public {
        require(msg.sender == owner() || msg.sender == BOUNTY, "EZ: not owner or bounty");
        harvest();
        uint balance = IBEP20(TOKEN).balanceOf(address(this));
        uint forDev = balance.calcPortionFromBasisPoints(DEV_PERCENTAGE);
        uint forRestake = balance.calcPortionFromBasisPoints(RESTAKE_PERCENTAGE);
        uint forBooster = balance.calcPortionFromBasisPoints(BOOSTER_PERCENTAGE);
        uint forDistribution = balance - (forDev + forRestake + forBooster);
        if (FUND_BOOSTER) {
            boost(forBooster);
        }
        restake(forRestake);
        IBEP20(TOKEN).transfer(DEV, forDev);
        IBEP20(TOKEN).transfer(BOUNTY, forDistribution);
        TOKEN_DISTRIBUTED += forDistribution;
    }

    function boost(uint amount) internal {
        ICakePool(POOL).deposit(amount, 0);
    }
    // requires this contract to have some CAKE >= amount and it should be approved 
    function seedBooster(uint amount) public onlyOwner() {
        ICakePool(POOL).deposit(amount, BOOSTER_DURATION);
    }
    // create farm booster proxy
    function createFarmBoosterProxy() public onlyOwner() {
        IFarmBoosterProxyFactory(FARM_BOOSTER_PROXY_FACTORY).createFarmBoosterProxy();
    }
    // for one time boost activation
    function activateBoost() public onlyOwner() {
        IFarmBooster(FARM_BOOSTER).activate(POOL_ID);
    }
    // get farm booster proxy address 
    function getFarmBoosterProxy() public onlyOwner() {
        FARM_BOOSTER_PROXY = IFarmBoosterProxyFactory(FARM_BOOSTER_PROXY_FACTORY).proxyContract(address(this));
    }

    function extendBoosterDuration(uint amount, uint duration) public onlyOwner() {
        ICakePool(POOL).deposit(amount, duration);
    }
    // withdraw staked CAKE for booster pool, in case pancakeswap decides to switch off the booster pools
    function withdrawBoosterCakeByAmount(uint amount) public onlyOwner() {
        ICakePool(POOL).withdrawByAmount(amount);
    }

    function withdrawBoosterCakeByShares(uint shares) public onlyOwner() {
        ICakePool(POOL).withdraw(shares);
    }

    function withdrawBoosterCake() public onlyOwner() {
        ICakePool(POOL).withdrawAll();
    }

    function sendRemainingTokensToDistributor() public onlyOwner() {
        IBEP20(TOKEN).transfer(DISTRIBUTOR, IBEP20(TOKEN).balanceOf(address(this)));
    }
    // IF ANY leftover
    function withdrawRemainingBnb() public onlyOwner() {
        payable(msg.sender).transfer(address(this).balance);
    }
    // from this contract. if any leftovers
    function withdrawRemainingTokens(address token) public onlyOwner() {
        IBEP20(token).transfer(msg.sender, IBEP20(token).balanceOf(address(this)));
    }
    // NOTE:- this is for testing only, LP tokens will be locked forever
    // function withdrawLpTokensFromProxyPool(uint amount) public onlyOwner() {
        // IFarmBoosterProxy(FARM_BOOSTER_PROXY).withdraw(POOL_ID, amount);
    // }
    // needed to transfer LP tokens from pool to boosted pool
    function withdrawLpTokensFromMasterChef(uint amount) public onlyOwner() {
        IMasterChef(MASTERCHEF).withdraw(POOL_ID, amount);
    }
    // generic because need to approve multiple tokens to multiple contracts
    function getTokenApproved(address token, address approveFor) public onlyOwner() {
        IBEP20(token).approve(approveFor, MAX_INT);
    }

    fallback() external payable {}

    receive() external payable {}

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}