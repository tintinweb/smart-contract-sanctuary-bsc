// SPDX-License-Identifier: MIT
// ref: https://etherscan.io/address/0x5c69bee701ef814a2b6a3edd4b1652cb9cc5aa6f/advanced#code
pragma solidity ^0.8.11;

import "./OBXExchange.sol";

contract OBXFactory {
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;
    
    address public obxReferral;

    constructor(address _obxReferral){
        obxReferral = _obxReferral;
    }

    function createPair(address tokenA, address tokenB, address _obxReferral)
        external
        returns (address pair)
    {
        require(tokenA != tokenB, "Token addresses are identical");
        require(_obxReferral == obxReferral, "invalid referral contract");
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "Token address cannot be null");
        require(getPair[token0][token1] == address(0), "Pair already exist");

        pair = address(new OBXExchange(tokenA, tokenB, _obxReferral));

        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;
        allPairs.push(pair);

        return pair;
    }

    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IERC20.sol";
import {LinkedListLib} from "./LinkedList.sol";
import {OPVSetLib} from "./OPVSet.sol";
import {PVNodeLib} from "./PVNode.sol";

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

interface IOBXReferral {
    /**
     * @dev Record referral.
     */
    function recordReferral(address user, address referrer) external;

    /**
     * @dev Record referral commission.
     */
    function recordReferralCommission(address referrer, uint256 totalAmount, uint256 commission, address token) external;

    /**
    * @dev Returns referral count
    */
    function getReferralCount(address _referrer) external view returns (uint256);

    /**
    * @dev Returns referral rate
    */
    function getComissionRate(address _referrer) external view returns (uint256);
    
    /**
     * @dev Get the referrer address that referred the user.
     */
    function getReferrer(address user) external view returns (address);
}

contract OBXExchange is Ownable,ReentrancyGuard {
    
    address public factory;
    address public tokenA;
    address public tokenB;
    address public USDCToken = 0x96F7e7fd1e17fe3a18d8B8b9CE6961fE7285baaB;
    address public USDTToken = 0x96F7e7fd1e17fe3a18d8B8b9CE6961fE7285baaB;
    address public BRZToken = 0xDE9d23B88231750d3C49282467c37e0b364F21a2;
    address public KRSTMToken = 0x8a9424745056Eb399FD19a0EC26A14316684e274;
    address public deployer = 0x55ADe9E7143bc597261e8D068c08817A932955df;
    // change after deployment of this contracts to correct address
    address public synteticPool = 0x55ADe9E7143bc597261e8D068c08817A932955df;
    address public stakingPool = 0x55ADe9E7143bc597261e8D068c08817A932955df;
    address public lotteryPool = 0x55ADe9E7143bc597261e8D068c08817A932955df;
    address public obxReferralAddress;

    uint16 public feeRate;
    uint256 public tokenAaccumulatedFee;
    uint256 public tokenBaccumulatedFee;

    // OBX referral contract address.
    IOBXReferral public obxReferral;

    IUniswapV2Router02 public uniswapRouter;

    constructor(address _tokenA, address _tokenB, address _obxReferral) {
        tokenA = _tokenA;
        tokenB = _tokenB;
        factory = msg.sender;
        obxReferral = IOBXReferral(_obxReferral);
        obxReferralAddress = _obxReferral;
        _transferOwnership(deployer);
        
        IUniswapV2Router02 _uniswapRouter = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        
        uniswapRouter = _uniswapRouter;

    }

    // addr A deposit B token, C many
    mapping(address => mapping(address => uint256)) deposits;

    // token A, price B, orders[seller, amount]
    mapping(address => mapping(uint256 => LinkedListLib.LinkedList))
        public orderBook;

    // addr A: [[sellOrderId, price, volume]]
    OPVSetLib.OPVset private _sellOrders;
    OPVSetLib.OPVset private _buyOrders;

    // [[price, volume]]
    PVNodeLib.PVnode[] private sellOB;
    PVNodeLib.PVnode[] private buyOB;
    
    //A way to store filled orders

    event Trade(uint otype, uint64 indexed price, uint256 amountGet, uint256 amountGive, address indexed userFill, address indexed userFilled, uint256 timestamp);
  
    function distributeFees() public returns (bool) {
        if(tokenA == KRSTMToken){

            IERC20(tokenA).transfer(deployer, tokenAaccumulatedFee/3);
            IERC20(tokenA).transfer(synteticPool, tokenAaccumulatedFee/3);
            IERC20(tokenA).transfer(lotteryPool, tokenAaccumulatedFee/3);

        } else if (tokenA == USDCToken || tokenA == USDTToken){

            IERC20(tokenA).transfer(deployer, tokenAaccumulatedFee / 10**12);

        } else {

            IERC20(tokenA).transfer(deployer, tokenAaccumulatedFee);

        }

        if(tokenB == USDCToken){

            IERC20(tokenB).transfer(deployer, (tokenBaccumulatedFee/2) / 10**12);
            IERC20(tokenB).transfer(stakingPool, (tokenBaccumulatedFee/2) / 10**12);

        } else if (tokenB == BRZToken){

            IERC20(tokenB).transfer(deployer, tokenBaccumulatedFee / 10**14);

        } else{ 

            IERC20(tokenB).transfer(deployer, tokenBaccumulatedFee);

        }

        tokenAaccumulatedFee = 0;
        tokenBaccumulatedFee = 0;
        return true;
    }

    //In case of new router version
    function changeRouter(address _routerAddress) public onlyOwner() {
        
        IUniswapV2Router02 _uniswapRouter = IUniswapV2Router02(_routerAddress);
        
        uniswapRouter = _uniswapRouter;

    }

    function deposit(address tokenAddress, uint256 amount)
        private
        returns (bool)
    {
        require(
            tokenAddress == tokenA || tokenAddress == tokenB,
            "Deposited token is not in the pool"
        );
        deposits[msg.sender][tokenAddress] += amount;
        if(tokenAddress == USDCToken || tokenAddress == USDTToken){
            amount = amount / 10**12;
        } else if (tokenAddress == BRZToken){
            amount = amount / 10**14;
        }
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        
        return true;
    }

    function withdraw(address tokenAddress, uint256 amount)
        private
        returns (bool)
    {
        require(
            tokenAddress == tokenA || tokenAddress == tokenB,
            "Withdrawn token is not in the pool"
        );
        require(
            deposits[msg.sender][tokenAddress] >= amount,
            "Withdraw amount exceeds deposited"
        );
        deposits[msg.sender][tokenAddress] -= amount;
        if(tokenAddress == USDCToken || tokenAddress == USDTToken){
            amount = amount / 10**12;
        } else if (tokenAddress == BRZToken){
            amount = amount / 10**14;
        }
        IERC20(tokenAddress).transfer(msg.sender, amount);
        return true;
    }
    
    function setEcosystemWallets(address _synteticContract, address _stakingContract, address _lotteryContract ) public onlyOwner {
        synteticPool = _synteticContract;
        stakingPool = _stakingContract;
        lotteryPool = _lotteryContract;
    }

    function swapTokensToKRSTM(address token,uint256 tokenAmount) private {
        // generate the swap pair path of tokens
        address[] memory path;
        if(token != 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd){
            path = new address[](3);
            path[0] = token;
            path[1] = uniswapRouter.WETH();
            path[2] = KRSTMToken;
       } else{
            path = new address[](2);
            path[0] = token;
            path[1] = KRSTMToken;
       }

        if(token == USDCToken || token == USDTToken){
            tokenAmount = tokenAmount / 10**12;
        } else if (token == BRZToken){
            tokenAmount = tokenAmount / 10**14;
        }

        IERC20(token).approve(address(uniswapRouter), tokenAmount);

        // make the swap
        uniswapRouter.swapExactTokensForTokens(
            tokenAmount,
            0, // accept any amount of Tokens out
            path,
            obxReferralAddress, // The contract
            block.timestamp + 300
        );
    }

    function getDeposits(address account, address tokenAddress)
        external
        view
        returns (uint256)
    {
        require(
            tokenAddress == tokenA || tokenAddress == tokenB,
            "Token is not in the pool"
        );
        return deposits[account][tokenAddress];
    }

    // Sell
    function newSellOrder(
        uint64 price,
        uint256 sellAmount,
        uint256 priceIdx,
        address _referrer
    ) external nonReentrant returns (bool) {
        // get priceIdx using the FE
        require(
            buyOB[priceIdx].price == price && sellOB[priceIdx].price == price,
            "Price does not match the index"
        );

        deposit(tokenA, sellAmount);
        
        //Record Referral
        if (sellAmount > 0 && address(obxReferral) != address(0) && _referrer != address(0) && _referrer != msg.sender && obxReferral.getReferrer(msg.sender) == address(0)) {
            obxReferral.recordReferral(msg.sender, _referrer);
        }
        

        if(IERC20(KRSTMToken).balanceOf(msg.sender) > 6.75 * 10 **18){
           feeRate = 75;
        } else if(IERC20(KRSTMToken).balanceOf(msg.sender) > 2.25 * 10 **18){
           feeRate = 250;
        } else if(IERC20(KRSTMToken).balanceOf(msg.sender) > 0.75 * 10 **18){
           feeRate = 500;
        } else if(IERC20(KRSTMToken).balanceOf(msg.sender) > 0.25 * 10 **18){
           feeRate = 750;
        } else{
           feeRate = 1000;
        }

        uint256 len = orderBook[tokenB][price].length;
        for (uint8 i = 0; i < len; i++) {
            bytes32 head_ = orderBook[tokenB][price].head;
            uint256 buyAmount = orderBook[tokenB][price]
                .nodes[head_]
                .order
                .amount;

            if (sellAmount == 0) {
                return true;
            } else if ((price * sellAmount) / 1000 >= buyAmount) {
                if(feeRate > 0){
              
                    uint256 currentFee = sellAmount * feeRate / 1000000;
                    
                    deposits[msg.sender][tokenA] -= currentFee;
                    sellAmount -= currentFee;
                    
                    address referrer = obxReferral.getReferrer(msg.sender);

                    if(referrer != address(0) && obxReferral.getReferralCount(referrer) >= 5){
                        
                        uint256 referralCommissionRate = obxReferral.getComissionRate(referrer);

                        uint256 referralAmount = currentFee*referralCommissionRate/10000;

                        obxReferral.recordReferralCommission(referrer,sellAmount,referralAmount,tokenA);

                        tokenAaccumulatedFee += currentFee - referralAmount;

                        swapTokensToKRSTM(tokenA,referralAmount);

                    } else{
                        tokenAaccumulatedFee += currentFee;
                    }

                }
                // sell amount >= buy amount
                LinkedListLib.Order memory o = orderBook[tokenB][price]
                    .nodes[head_]
                    .order;
                LinkedListLib.popHead(orderBook[tokenB][price]);
                OPVSetLib._remove(_buyOrders, o.seller, head_);
                PVNodeLib._subVolume(buyOB, priceIdx, o.amount);

                uint256 amountGiven = (o.amount / price) * 100;

                deposits[o.seller][tokenB] -= o.amount;
                deposits[msg.sender][tokenA] -= amountGiven;

                if(tokenB == USDCToken){
                  IERC20(tokenB).transfer(msg.sender, o.amount / 10**12);
                } else if (tokenB == BRZToken){
                  IERC20(tokenB).transfer(msg.sender, o.amount / 10**14);
                }

                if(tokenA == USDTToken || tokenA == USDCToken){
                IERC20(tokenA).transfer(o.seller, amountGiven / 10**12);
                } else{
                IERC20(tokenA).transfer(o.seller, amountGiven);
                }
               
                emit Trade(0, price, o.amount, amountGiven, msg.sender, o.seller, block.timestamp);

                sellAmount -= amountGiven;

            } else if (buyAmount > (price * sellAmount) / 1000) {
                if(feeRate > 0){
       
                    uint256 currentFee = sellAmount * feeRate / 1000000;

                    deposits[msg.sender][tokenA] -= currentFee;
                    sellAmount -= currentFee;

                    address referrer = obxReferral.getReferrer(msg.sender);

                    if(referrer != address(0) && obxReferral.getReferralCount(referrer) >= 5){
                        
                        uint256 referralCommissionRate = obxReferral.getComissionRate(referrer);

                        uint256 referralAmount = currentFee*referralCommissionRate/10000;

                        obxReferral.recordReferralCommission(referrer,sellAmount,referralAmount,tokenA);

                        tokenAaccumulatedFee += currentFee - referralAmount;
                        
                        swapTokensToKRSTM(tokenA,referralAmount);

                    } else{
                        tokenAaccumulatedFee += currentFee;
                    }

                }

                uint256 amountReceive = (price * sellAmount) / 1000;

                LinkedListLib.Order memory o = orderBook[tokenB][price]
                    .nodes[head_]
                    .order;
                orderBook[tokenB][price].nodes[head_].order.amount -=
                    amountReceive;
                OPVSetLib._subVolume(
                    _buyOrders,
                    o.seller,
                    head_,
                    amountReceive
                );
                PVNodeLib._subVolume(buyOB, priceIdx, amountReceive);

                deposits[o.seller][tokenB] -= amountReceive;
                deposits[msg.sender][tokenA] -= sellAmount;

                
                if(tokenB == USDCToken){
                  IERC20(tokenB).transfer(msg.sender, amountReceive / 10**12);
                } else if (tokenB == BRZToken){
                  IERC20(tokenB).transfer(msg.sender, amountReceive / 10**14);
                }

                if(tokenA == USDTToken || tokenA == USDCToken){
                IERC20(tokenA).transfer(o.seller, sellAmount / 10**12);
                } else{
                IERC20(tokenA).transfer(o.seller, sellAmount);
                }
                
                emit Trade(0, price, amountReceive , sellAmount, msg.sender, o.seller, block.timestamp);

                sellAmount = 0;
            }
        }
        // new sell order
        if (orderBook[tokenA][price].length == 0 && sellAmount > 0) {
            bytes32 orderId = LinkedListLib.initHead(
                orderBook[tokenA][price],
                msg.sender,
                sellAmount
            );
            OPVSetLib._add(_sellOrders, msg.sender, orderId, price, sellAmount);
            PVNodeLib._addVolume(sellOB, priceIdx, sellAmount);
        } else if (sellAmount > 0) {
            bytes32 orderId = LinkedListLib.addNode(
                orderBook[tokenA][price],
                msg.sender,
                sellAmount
            );
            OPVSetLib._add(_sellOrders, msg.sender, orderId, price, sellAmount);
            PVNodeLib._addVolume(sellOB, priceIdx, sellAmount);
        }

        if(tokenBaccumulatedFee >= 50 * 10 ** 18 ){
            distributeFees();
        }

        return true;
    }

    function getAllSellOrders(uint64 price)
        external
        view
        returns (LinkedListLib.Order[] memory)
    {
        LinkedListLib.Order[] memory orders = new LinkedListLib.Order[](
            orderBook[tokenA][price].length
        );

        bytes32 currId = orderBook[tokenA][price].head;

        for (uint256 i = 0; i < orderBook[tokenA][price].length; i++) {
            orders[i] = orderBook[tokenA][price].nodes[currId].order;
            currId = orderBook[tokenA][price].nodes[currId].next;
        }
        return orders;
    }

    function activeSellOrders()
        external
        view
        returns (OPVSetLib.OPVnode[] memory)
    {
        OPVSetLib.OPVnode[] memory sellOrders = new OPVSetLib.OPVnode[](
            _sellOrders._orders[msg.sender].length
        );

        for (uint256 i = 0; i < _sellOrders._orders[msg.sender].length; i++) {
            sellOrders[i] = _sellOrders._orders[msg.sender][i];
        }
        return sellOrders;
    }

    function deleteSellOrder(
        uint64 price,
        bytes32 orderId,
        uint256 priceIdx
    ) external returns (bool) {
        require(
            buyOB[priceIdx].price == price && sellOB[priceIdx].price == price,
            "Price does not match the index"
        );

        LinkedListLib.Order memory o = orderBook[tokenA][price]
            .nodes[orderId]
            .order;
        require(msg.sender == o.seller, "Seller does not match the caller");

        withdraw(tokenA, o.amount);

        LinkedListLib.deleteNode(orderBook[tokenA][price], orderId);
        OPVSetLib._remove(_sellOrders, msg.sender, orderId);
        PVNodeLib._subVolume(sellOB, priceIdx, o.amount);

        return true;
    }

    // Buy
    function newBuyOrder(
        uint64 price,
        uint256 buyAmount,
        uint256 priceIdx,
        address _referrer
    ) external nonReentrant returns (bool) {
        // get priceIdx using the FE
        require(
            buyOB[priceIdx].price == price && sellOB[priceIdx].price == price,
            "Price does not match the index"
        );

        deposit(tokenB, (price * buyAmount) / 1000);
        
        //Record Referral
        if (buyAmount > 0 && address(obxReferral) != address(0) && _referrer != address(0) && _referrer != msg.sender && obxReferral.getReferrer(msg.sender) == address(0)) {
            obxReferral.recordReferral(msg.sender, _referrer);
        }

        if(IERC20(KRSTMToken).balanceOf(msg.sender) > 6.75 * 10 **18){
           feeRate = 75;
        } else if(IERC20(KRSTMToken).balanceOf(msg.sender) > 2.25 * 10 **18){
           feeRate = 250;
        } else if(IERC20(KRSTMToken).balanceOf(msg.sender) > 0.75 * 10 **18){
           feeRate = 500;
        } else if(IERC20(KRSTMToken).balanceOf(msg.sender) > 0.25 * 10 **18){
           feeRate = 750;
        } else{
           feeRate = 1000;
        }

        uint256 len = orderBook[tokenA][price].length;
        for (uint8 i = 0; i < len; i++) {
            bytes32 head_ = orderBook[tokenA][price].head;
            uint256 sellAmount = orderBook[tokenA][price]
                .nodes[head_]
                .order
                .amount;

            if (buyAmount == 0) {
                return true;
            } else if (buyAmount >= sellAmount) {
                if(feeRate > 0){
                   
                    uint256 amountInQuote = (price * buyAmount) / 1000;
                    uint256 currentFee = amountInQuote * feeRate / 1000000;

                    address referrer = obxReferral.getReferrer(msg.sender);

                    if(referrer != address(0) && obxReferral.getReferralCount(referrer) >= 5){
                        
                        uint256 referralCommissionRate = obxReferral.getComissionRate(referrer);

                        uint256 referralAmount = currentFee*referralCommissionRate/10000;

                        obxReferral.recordReferralCommission(referrer,buyAmount,referralAmount,tokenB);

                        tokenBaccumulatedFee += currentFee - referralAmount;

                        swapTokensToKRSTM(tokenB,referralAmount);

                    } else{

                        tokenBaccumulatedFee += currentFee;

                    }

                    deposits[msg.sender][tokenB] -= currentFee;
                    buyAmount -= currentFee;
                }
                // buy amount >= sell amount
                LinkedListLib.Order memory o = orderBook[tokenA][price]
                    .nodes[head_]
                    .order;
                LinkedListLib.popHead(orderBook[tokenA][price]);
                OPVSetLib._remove(_sellOrders, o.seller, head_);
                PVNodeLib._subVolume(sellOB, priceIdx, o.amount);
                
                uint256 amountGiven = (price * o.amount) / 1000;

                deposits[o.seller][tokenA] -= o.amount;
                deposits[msg.sender][tokenB] -= amountGiven;
                
                if(tokenA == USDTToken || tokenA == USDCToken){
                 IERC20(tokenA).transfer(msg.sender, o.amount / 10**12);
                } else{
                 IERC20(tokenA).transfer(msg.sender, o.amount);
                }

                if(tokenB == USDCToken){
                  IERC20(tokenB).transfer(o.seller, amountGiven / 10**12);
                } else if (tokenB == BRZToken){
                  IERC20(tokenB).transfer(o.seller, amountGiven / 10**14);
                } else{
                  IERC20(tokenB).transfer(o.seller, amountGiven); 
                }

                emit Trade(1, price, o.amount, amountGiven, msg.sender, o.seller, block.timestamp);

                buyAmount -= o.amount;
            } else if (sellAmount > buyAmount) {
                if(feeRate > 0){
                    uint256 amountInQuote = (price * buyAmount) / 1000;
                    uint256 currentFee = amountInQuote * feeRate / 1000000;
                    
                    address referrer = obxReferral.getReferrer(msg.sender);

                    if(referrer != address(0) && obxReferral.getReferralCount(referrer) >= 5){
                        
                        uint256 referralCommissionRate = obxReferral.getComissionRate(referrer);

                        uint256 referralAmount = currentFee*referralCommissionRate/10000;

                        obxReferral.recordReferralCommission(referrer,buyAmount,referralAmount,tokenB);

                        tokenBaccumulatedFee += currentFee - referralAmount;

                        swapTokensToKRSTM(tokenB,referralAmount);

                    } else{

                        tokenBaccumulatedFee += currentFee;

                    }

                    deposits[msg.sender][tokenB] -= currentFee;
                    buyAmount -= currentFee;
                }

                uint256 amountGiven = (price * buyAmount) / 1000;

                LinkedListLib.Order memory o = orderBook[tokenA][price]
                    .nodes[head_]
                    .order;
                orderBook[tokenA][price].nodes[head_].order.amount -= buyAmount;
                OPVSetLib._subVolume(_sellOrders, o.seller, head_, buyAmount);
                PVNodeLib._subVolume(sellOB, priceIdx, buyAmount);

                deposits[o.seller][tokenA] -= buyAmount;
                deposits[msg.sender][tokenB] -= amountGiven;

                if(tokenA == USDTToken || tokenA == USDCToken){
                 IERC20(tokenA).transfer(msg.sender, buyAmount / 10**12);
                } else{
                 IERC20(tokenA).transfer(msg.sender, buyAmount);
                }

                if(tokenB == USDCToken){
                  IERC20(tokenB).transfer(o.seller, amountGiven / 10**12);
                } else if (tokenB == BRZToken){
                  IERC20(tokenB).transfer(o.seller, amountGiven / 10**14);
                } else{
                  IERC20(tokenB).transfer(o.seller, amountGiven);
                }
                
                emit Trade(1, price, buyAmount, amountGiven , msg.sender, o.seller, block.timestamp);

                buyAmount = 0;
            }
        }
        // new buy order
        if (orderBook[tokenB][price].length == 0 && buyAmount > 0) {
            bytes32 orderId = LinkedListLib.initHead(
                orderBook[tokenB][price],
                msg.sender,
                (price * buyAmount) / 1000
            );
            OPVSetLib._add(
                _buyOrders,
                msg.sender,
                orderId,
                price,
                (price * buyAmount) / 1000
            );
            PVNodeLib._addVolume(buyOB, priceIdx, (price * buyAmount) / 1000);
        } else if (buyAmount > 0) {
            bytes32 orderId = LinkedListLib.addNode(
                orderBook[tokenB][price],
                msg.sender,
                (price * buyAmount) / 1000
            );
            OPVSetLib._add(
                _buyOrders,
                msg.sender,
                orderId,
                price,
                (price * buyAmount) / 1000
            );
            PVNodeLib._addVolume(buyOB, priceIdx, (price * buyAmount) / 1000);
        }

        if(tokenBaccumulatedFee >= 50 * 10 ** 18 ){
            distributeFees();
        }
        

        return true;
    }

    function deleteBuyOrder(
        uint64 price,
        bytes32 orderId,
        uint256 priceIdx
    ) external returns (bool) {
        require(
            buyOB[priceIdx].price == price && sellOB[priceIdx].price == price,
            "Price does not match the index"
        );

        LinkedListLib.Order memory o = orderBook[tokenB][price]
            .nodes[orderId]
            .order;
        require(msg.sender == o.seller, "Seller does not match the caller");

        withdraw(tokenB, o.amount);

        LinkedListLib.deleteNode(orderBook[tokenB][price], orderId);
        OPVSetLib._remove(_buyOrders, msg.sender, orderId);
        PVNodeLib._subVolume(buyOB, priceIdx, o.amount);

        return true;
    }

    function getAllBuyOrders(uint64 price)
        external
        view
        returns (LinkedListLib.Order[] memory)
    {
        LinkedListLib.Order[] memory orders = new LinkedListLib.Order[](
            orderBook[tokenB][price].length
        );

        bytes32 currId = orderBook[tokenB][price].head;

        for (uint256 i = 0; i < orderBook[tokenB][price].length; i++) {
            orders[i] = orderBook[tokenB][price].nodes[currId].order;
            currId = orderBook[tokenB][price].nodes[currId].next;
        }
        return orders;
    }

    function activeBuyOrders()
        external
        view
        returns (OPVSetLib.OPVnode[] memory)
    {
        OPVSetLib.OPVnode[] memory buyOrders = new OPVSetLib.OPVnode[](
            _buyOrders._orders[msg.sender].length
        );

        for (uint256 i = 0; i < _buyOrders._orders[msg.sender].length; i++) {
            buyOrders[i] = _buyOrders._orders[msg.sender][i];
        }
        return buyOrders;
    }

    // sellOB + buyOB functions
    function getPVobs()
        external
        view
        returns (PVNodeLib.PVnode[] memory, PVNodeLib.PVnode[] memory)
    {
        return (sellOB, buyOB);
    }

    function initPVnode(uint64 price) external returns (uint256) {
        if (
            orderBook[tokenA][price].tail == "" &&
            orderBook[tokenB][price].tail == ""
        ) {
            orderBook[tokenA][price].tail = "1"; // placeholder
            sellOB.push(PVNodeLib.PVnode(price, 0));
            buyOB.push(PVNodeLib.PVnode(price, 0));
            return buyOB.length - 1;
        }
        revert("Price already exist");
    }

    function getIndexOfPrice(uint64 price) external view returns (uint256) {
        for (uint256 i = 0; i < sellOB.length; i++) {
            if (sellOB[i].price == price) {
                return i;
            }
        }
        revert("Price is not in the array");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IERC20 {
    function balanceOf(address tokenOwner) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function approve(address delegate, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

library LinkedListLib {
    struct Order {
        address seller;
        uint256 amount;
    }

    struct Node {
        bytes32 next;
        Order order;
    }

    struct LinkedList {
        uint256 length;
        bytes32 head;
        bytes32 tail;
        mapping(bytes32 => LinkedListLib.Node) nodes;
    }

    function initHead(
        LinkedList storage self,
        address _seller,
        uint256 _amount
    ) public returns (bytes32) {
        Order memory o = Order(_seller, _amount);
        Node memory n = Node(0, o);

        bytes32 id = keccak256(
            abi.encodePacked(_seller, _amount, self.length, block.timestamp)
        );

        self.nodes[id] = n;
        self.head = id;
        self.tail = id;
        self.length = 1;

        return id;
    }

    function getNode(LinkedList storage self, bytes32 _id)
        public
        view
        returns (Node memory)
    {
        return self.nodes[_id];
        // Q: Why "getter func" instead of `public`?
        // A: https://ethereum.stackexchange.com/questions/67137/why-creating-a-private-variable-and-a-getter-instead-of-just-creating-a-public-v
    }

    function getLength(LinkedList storage self) public view returns (uint256) {
        return self.length;
    }

    function addNode(
        LinkedList storage self,
        address _seller,
        uint256 _amount
    ) public returns (bytes32) {
        Order memory o = Order(_seller, _amount);
        Node memory n = Node(0, o);

        bytes32 id = keccak256(
            abi.encodePacked(_seller, _amount, self.length, block.timestamp)
        );

        self.nodes[id] = n;
        self.nodes[self.tail].next = id;
        self.tail = id;
        self.length += 1;
        return id;
    }

    function popHead(LinkedList storage self) public returns (bool) {
        bytes32 currHead = self.head;

        self.head = self.nodes[currHead].next;

        // delete's don't work for mappings so have to be set to 0
        // deleting is not necessary but we get partial refund
        delete self.nodes[currHead];
        self.length -= 1;
        return true;
    }

    function deleteNode(LinkedList storage self, bytes32 _id)
        public
        returns (bool)
    {
        if (self.head == _id) {
            require(
                self.nodes[_id].order.seller == msg.sender,
                "Unauthorised to delete this order."
            );
            popHead(self);
            return true;
        }

        bytes32 curr = self.nodes[self.head].next;
        bytes32 prev = self.head;

        // skipping node at index=0 (cuz its the head)
        for (uint256 i = 1; i < self.length; i++) {
            if (curr == _id) {
                require(
                    self.nodes[_id].order.seller == msg.sender,
                    "Unauthorised to delete this order."
                );
                self.nodes[prev].next = self.nodes[curr].next;
                delete self.nodes[curr];
                self.length -= 1;
                return true;
            }
            prev = curr;
            curr = self.nodes[prev].next;
        }
        revert("Order ID not found.");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

library PVNodeLib {
    // price-volume node
    struct PVnode {
        uint64 price;
        uint256 volume;
    }

    function _addVolume(
        PVnode[] storage ob,
        uint256 index,
        uint256 changeAmount
    ) internal returns (bool) {
        ob[index].volume += changeAmount;
        return true;
    }

    function _subVolume(
        PVnode[] storage ob,
        uint256 index,
        uint256 changeAmount
    ) internal returns (bool) {
        ob[index].volume -= changeAmount;
        return true;
    }
}

// SPDX-License-Identifier: MIT
// inspired by: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/EnumerableSet.sol
pragma solidity ^0.8.11;

library OPVSetLib {
    struct OPVnode {
        bytes32 _orderId;
        uint64 _price;
        uint256 _volume;
    }

    struct OPVset {
        mapping(address => OPVnode[]) _orders;
        mapping(bytes32 => uint256) _indexes;
    }

    function _contains(OPVset storage set, bytes32 orderId)
        internal
        view
        returns (bool)
    {
        // 0 is a sentinel value
        return set._indexes[orderId] != 0;
    }

    function _at(
        OPVset storage set,
        address userAddress,
        uint256 index
    ) internal view returns (OPVnode memory) {
        return set._orders[userAddress][index];
    }

    function _add(
        OPVset storage set,
        address userAddress,
        bytes32 orderId,
        uint64 price,
        uint256 volume
    ) internal returns (bool) {
        if (!_contains(set, orderId)) {
            set._orders[userAddress].push(OPVnode(orderId, price, volume));
            set._indexes[orderId] = set._orders[userAddress].length;
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            return true;
        } else {
            return false;
        }
    }

    function _remove(
        OPVset storage set,
        address userAddress,
        bytes32 orderId
    ) internal returns (bool) {
        uint256 orderIdIndex = set._indexes[orderId];

        if (orderIdIndex != 0) {
            uint256 toDeleteIndex = orderIdIndex - 1;
            uint256 lastIndex = set._orders[userAddress].length - 1;

            if (lastIndex != toDeleteIndex) {
                OPVnode memory lastOPVnode = set._orders[userAddress][
                    lastIndex
                ];

                // Move the last value to the index where the value to delete is
                set._orders[userAddress][toDeleteIndex] = lastOPVnode;
                // Update the index for the moved value
                set._indexes[lastOPVnode._orderId] = orderIdIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._orders[userAddress].pop();

            // Delete the index for the deleted slot
            delete set._indexes[orderId];

            return true;
        } else {
            return false;
        }
    }

    function _addVolume(
        OPVset storage set,
        address userAddress,
        bytes32 orderId,
        uint256 volume
    ) internal returns (bool) {
        uint256 orderIdIndex = set._indexes[orderId];

        if (orderIdIndex != 0) {
            set._orders[userAddress][orderIdIndex - 1]._volume += volume;
            return true;
        } else {
            return false;
        }
    }

    function _subVolume(
        OPVset storage set,
        address userAddress,
        bytes32 orderId,
        uint256 volume
    ) internal returns (bool) {
        uint256 orderIdIndex = set._indexes[orderId];

        if (orderIdIndex != 0) {
            set._orders[userAddress][orderIdIndex - 1]._volume -= volume;
            return true;
        } else {
            return false;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}