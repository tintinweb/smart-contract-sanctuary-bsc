// SPDX-License-Identifier: MIT

/* 
 * \file    smartInvest.sol
 * \brief   Small contract to help you invest smartly. 
 *          Pass him the minimum of information, he takes care of the rest.
 *
 * \brief   Release note
 * \version 1.0
 * \date    2022/09/23
 * \details The beginning
 *
 * \todo    Let the service manage your balance.
 */

pragma solidity ^0.8.17;

import "../ERC20.sol";
import "../SafeMath.sol";
//import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/// https://docs.pancakeswap.finance/code/smart-contracts/pancakeswap-exchange/router-v2
interface IPancakeRouter01 {
    function WETH() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {}

contract smartInvest {
    using SafeMath for uint256;
    
    uint8 public constant NUMBER_OF_TOKENS = 4;     /// Up to 255
    uint8 public constant NUMBER_OF_OUTPUT = 3;
    address public constant FEE_ADDRESS = 0x0f770adBF4F3cD34519c9f7c38b732Ce66B4E98C;
    address public constant RAW_ADDRESS = 0x433718Fa4606b43120d97c7dc00187562135e593;

    address private routerAdd;
    address public admin;

    IPancakeRouter02 public pancakeSwapRouter;
    address public wbnb;

    struct investData {
        address user;
        uint timestamp;
        uint256[NUMBER_OF_TOKENS] quantityIn;
        uint256[NUMBER_OF_TOKENS] quantityOut;
        address swapToken;
    }
    investData[] private purchaseData;
    investData[] private saleData;

    address[NUMBER_OF_TOKENS] public cryptoAddress;
    address[NUMBER_OF_OUTPUT] public outputAddress;

    mapping(address => uint256[NUMBER_OF_TOKENS]) private internalPurchaseBalance;
    mapping(address => uint256[NUMBER_OF_OUTPUT]) private internalSaleBalance;

    event swapPurchase(address from, address tokenIn, uint256[NUMBER_OF_TOKENS] quantityIn, uint256[NUMBER_OF_TOKENS] quantityOut, address receiver);
    event swapSale(address from, uint256[NUMBER_OF_TOKENS] quantityIn, address tokenOut, uint256[NUMBER_OF_TOKENS] quantityOut, address receiver);
    
    event Paused();
    event Unpaused();
    bool public paused = false;

    constructor() {
        admin = msg.sender;

        routerAdd = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        pancakeSwapRouter = IPancakeRouter02(routerAdd);
        wbnb = pancakeSwapRouter.WETH();
       
        cryptoAddress[0] = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;      /// BTC
        cryptoAddress[1] = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;      /// ETH
        cryptoAddress[2] = 0x0Eb3a705fc54725037CC9e008bDede697f62F335;      /// ATOM
        cryptoAddress[3] = 0xF8A0BF9cF54Bb92F17374d9e9A321E6a111a51bD;      /// LINK

        outputAddress[0] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;      /// BUSD
        outputAddress[1] = wbnb;                                            /// BNB
        outputAddress[2] = RAW_ADDRESS;                                     /// RAW
    }

    /*
     * version : to know the contract version
     */
    function version() public pure returns (string memory) {
        return ("1.0");
    }

    /*
     * pause : to pause the contract
     */
    function pause() public {
        require(paused == false, "[smartInvest] pause : the contract is already paused");
        require(msg.sender == admin, "[smartInvest] pause : only admin");
        paused = true;
        emit Paused();
    }

    /*
     * upause : to unpause the contrat
     */
    function unpause() public {
        require(paused == true, "[smartInvest] unpause : the contract is not paused");
        require(msg.sender == admin, "[smartInvest] unpause : only admin");
        paused = false;
        emit Unpaused();
    }

    /*
     * manageFunds : to manage the user's funds depending on his internal balance
     */
    function manageFunds(address token, uint256 amount, uint256 internatlBalance) private returns (uint256 deduct) {
        if (internatlBalance < amount) {
            /// If the amount is greater than the internal balance, then we verify that we have the necessary allowance
            deduct = internatlBalance;
            uint256 amountRequired = amount - internatlBalance;
            require(ERC20(token).allowance(msg.sender, address(this)) >= amountRequired, "[smartInvest] manageFunds : the allowance is insufficient");
            require(ERC20(token).transferFrom(msg.sender, address(this), amountRequired), "[smartInvest] manageFunds : transfer failed");
        } else {
            deduct = amount;
        }
        require(ERC20(token).approve(address(pancakeSwapRouter), amount), "[smartInvest] manageFunds : approve failed");

        return (deduct);
    }

    /*
     * buyThisForMe : to ask the contract to buy the different tokens available
     */
    function buyThisForMe(address tokenIn, uint256[NUMBER_OF_TOKENS] calldata portionIn, uint256[NUMBER_OF_TOKENS] calldata amountOutMin, address recipient) public {
        require(purchaseData.length < type(uint256).max, "[smartInvest] buyThisForMe : the service is full");
        require(paused == false, "[smartInvest] buyThisForMe : the contract is paused");
        
        uint256 investAmount;
        for (uint8 i=0 ; i<NUMBER_OF_TOKENS ; i++) {
            require((investAmount + portionIn[i]) < (type(uint256).max), "[smartInvest] buyThisForMe : portion produce an overflow of capacity");
            investAmount += portionIn[i];
        }

        uint256 deduct = 0;
        for (uint8 i=0 ; i<NUMBER_OF_OUTPUT ; i++) {
            if (outputAddress[i] == tokenIn) {
                deduct = manageFunds(tokenIn, investAmount, internalSaleBalance[msg.sender][i]);
                break;
            }       
        }

        uint256 totalFees = 0;
        investData memory tempData;
        uint256[NUMBER_OF_TOKENS] memory allocation;
        bool handle = false;
        for (uint8 i=0 ; i<NUMBER_OF_TOKENS ; i++) {
            allocation[i] = portionIn[i];
            if (allocation[i] > 0) {
                handle = true;
                uint256 feeAmount = allocation[i].mul(getTaxPercentage(msg.sender)).div(10000);
                if (feeAmount > 0) {
                    totalFees += feeAmount;
                    allocation[i] -= feeAmount;
                }
                uint256 quantity = swap(tokenIn, cryptoAddress[i], allocation[i], amountOutMin[i], recipient);
                if (recipient == address(this)) {
                    internalPurchaseBalance[msg.sender][i] += quantity;
                }
                tempData.quantityIn[i] = allocation[i];
                tempData.quantityOut[i] = quantity;
            }
        }

        require(handle == true, "[smartInvest] sellThisForMe : all portions cannot be zero");

        if (deduct > 0) {
            for (uint8 j=0 ; j<NUMBER_OF_OUTPUT ; j++) {
                if (outputAddress[j] == tokenIn) {
                    internalSaleBalance[msg.sender][j] -= deduct;
                    break;
                }
            }
        }

        if (totalFees > 0) {
            ERC20(tokenIn).transfer(FEE_ADDRESS, totalFees);
        }
        tempData.user = msg.sender;
        tempData.timestamp = block.timestamp;
        tempData.swapToken = tokenIn;
        purchaseData.push(tempData);
        
        emit swapPurchase(msg.sender, tokenIn, tempData.quantityIn, tempData.quantityOut, recipient);
    }

    /*
     * sellThisForMe : to ask the contract to sell the different tokens available
     */
    function sellThisForMe(address tokenOut, uint256[NUMBER_OF_TOKENS] calldata portionIn, uint256[NUMBER_OF_TOKENS] calldata amountOutMin, address recipient) public {
        require(saleData.length < type(uint256).max, "[smartInvest] sellThisForMe : the service is full");
        require(paused == false, "[smartInvest] sellThisForMe : the contract is paused");

        investData memory tempData;
        bool handle = false;
        for (uint8 i=0 ; i<NUMBER_OF_TOKENS ; i++) {
            if (portionIn[i] > 0) {
                handle = true;
                uint256 deduct = manageFunds(cryptoAddress[i], portionIn[i], internalPurchaseBalance[msg.sender][i]);
                uint256 quantity = swap(cryptoAddress[i], tokenOut, portionIn[i], amountOutMin[i], recipient);
                internalPurchaseBalance[msg.sender][i] -= deduct;
                if (recipient == address(this)) {
                    for (uint8 j=0 ; j<NUMBER_OF_OUTPUT ; j++) {
                        if (outputAddress[j] == tokenOut) {
                            internalSaleBalance[msg.sender][j] += quantity;
                            break;
                        }
                    }
                }
                tempData.quantityIn[i] = portionIn[i];
                tempData.quantityOut[i] = quantity;
            }
        }

        require(handle == true, "[smartInvest] sellThisForMe : all portions cannot be zero");
        tempData.user = msg.sender;
        tempData.timestamp = block.timestamp;
        tempData.swapToken = tokenOut;
        saleData.push(tempData);

        emit swapSale(msg.sender, tempData.quantityIn, tokenOut, tempData.quantityOut, recipient);
    }

    /*
     * swap : to realize the swap (internal functioning of this contract)
     */
    function swap(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOutMin, address recipient) private returns (uint256 amountOut) {
       address[] memory path = getPath(tokenIn, tokenOut);
       uint[] memory amounts = pancakeSwapRouter.swapExactTokensForTokens(amountIn, amountOutMin, path, recipient, block.timestamp);

       return (amounts[path.length-1]);
    }

    /*
     * getPath : to get a swap path (internal functioning of this contract)
     */
    function getPath(address tokenIn, address tokenOut) private view returns (address[] memory path) {
        if (tokenIn == wbnb || tokenOut == wbnb) {
            path = new address[](2);
            path[0] = tokenIn;
            path[1] = tokenOut;
        } 
        else {
            path = new address[](3);
            path[0] = tokenIn;
            path[1] = wbnb;
            path[2] = tokenOut;
        }

        return (path);
    }

    /*
     * getAmountOutMin : to know the minimum amount we can get by doing a swap
     * If this function is called by the interface to evaluate what the user can have thanks to the swap, 
     * it will be necessary to first call getTaxPercentage() in order to know the number of input tokens to subtract.
     */
    function getAmountOutMin(address tokenIn, address tokenOut, uint256 amountIn) public view returns (uint256 amount) {
        address[] memory path = getPath(tokenIn, tokenOut);
        uint256[] memory amounts = pancakeSwapRouter.getAmountsOut(amountIn, path);
        
        return (amounts[path.length-1]);
    }

    /*
     * getTaxPercentage : to obtain the applicable tax percentage
     */
    function getTaxPercentage(address user) public view returns (uint8 taxPercentage) {
        uint256 rawBalance = ERC20(RAW_ADDRESS).balanceOf(user);
        uint8 rawDecimals = ERC20(RAW_ADDRESS).decimals();

        if (rawBalance >= (33000 * (10 ** rawDecimals))) {
            taxPercentage = 0;
        }
        else if (rawBalance >= (23000 * (10 ** rawDecimals))) {
            taxPercentage = 5;
        }
        else if (rawBalance >= (13000 * (10 ** rawDecimals))) {
            taxPercentage = 10;    
        }
        else {
            taxPercentage = 20;
        }

        return (taxPercentage);
    }

    /*
     * getBalance : to show the balance available for this service
     */
    function getBalance(address user, address tokenIn) public view returns (uint256) {
        return (ERC20(tokenIn).balanceOf(user));
    }

    /*
     * getAllowance : to show the user the amount of allowance available for this service
     */
    function getAllowance(address user, address tokenIn) public view returns (uint) {
        return (ERC20(tokenIn).allowance(user, address(this)));
    }

    /*
     * getSymbol : to show the token symbol
     */
    function getSymbol(address tokenIn) public view returns (string memory symbol) {
         return (ERC20(tokenIn).symbol());
    }

    /*
     * getDecimals : to know the number of decimals the token has
     */
    function getDecimals(address tokenIn) public view returns (uint8 decimals) {
        return (ERC20(tokenIn).decimals());
    }

    /*
     * getInternalPurchaseBalance : to know the internal balance related to the purchases of a user
     */
    function getInternalPurchaseBalance(address user) public view returns (uint256[NUMBER_OF_TOKENS] memory) {
        return (internalPurchaseBalance[user]);
    }

    /*
     * getInternalSaleBalance : to know the internal balance related to the sales of a user
     */
    function getInternalSaleBalance(address user) public view returns (uint256[NUMBER_OF_OUTPUT] memory) {
        return (internalSaleBalance[user]);
    }

    /*
     * getValueOfInternalPurchaseBalance : returns the value of a user's internal balance related to the purchase. This value is calculated according to an output token
     */
    function getValueOfInternalPurchaseBalance(address user, address tokenOut) public view returns (uint256 value) {
        for (uint8 i=0 ; i<NUMBER_OF_TOKENS ; i++) {
            if (internalPurchaseBalance[user][i] > 0) {
                value += getAmountOutMin(cryptoAddress[i], tokenOut, internalPurchaseBalance[user][i]);
            }
        }

        return (value);
    }

    /*
     * getValueOfInternalSaleBalance : returns the value of a user's internal balance related to the sale. This value is calculated according to an output token
     */
    function getValueOfInternalSaleBalance(address user, address tokenOut) public view returns (uint256 value) {
        for (uint8 i=0 ; i<NUMBER_OF_OUTPUT ; i++) {
            if (internalSaleBalance[user][i] > 0) {
                value += getAmountOutMin(outputAddress[i], tokenOut, internalSaleBalance[user][i]);
            }
        }

        return (value);
    }

    /*
     * getLengthOfPurchaseData : returns the current length of the structure containing the purchase data
     */
    function getLengthOfPurchaseData() public view returns (uint256 length) {
        return (purchaseData.length);
    }

    /*
     * getLengthOfSaleData : returns the current length of the structure containing the sale data
     */
    function getLengthOfSaleData() public view returns (uint256 length) {
        return (saleData.length);
    }

    /*
     * getPurchaseIndex : to know the index of the purchase structure, related to user address
     */
    function getPurchaseIndex(address user) public view returns (uint256[] memory indexList) {
        uint256 j = 0;
        for (uint256 i=0 ; i<purchaseData.length ; i++) {
            if (purchaseData[i].user == user) {
                j++;
            }
        }
        indexList = new uint256[](j);
        j = 0;
        for (uint256 i=0 ; i<purchaseData.length ; i++) {
            if (purchaseData[i].user == user) {
                indexList[j] = i;
                j++;
            }
        }

        return (indexList);
    }

    /*
     * getSaleIndex : to know the index of the sale structure, related to user address
     */
    function getSaleIndex(address user) public view returns (uint256[] memory indexList) {
        uint256 j = 0;
        for (uint256 i=0 ; i<saleData.length ; i++) {
            if (saleData[i].user == user) {
                j++;
            }
        }
        indexList = new uint256[](j);
        j = 0;
        for (uint256 i=0 ; i<saleData.length ; i++) {
            if (saleData[i].user == user) {
                indexList[j] = i;
                j++;
            }
        }

        return (indexList);
    }

    /*
     * getPurchaseData : returns the purchase data according to a given index (index that can be retrieved with the getPurchaseIndex function)
     */
    function getPurchaseData(uint256 index) public view returns (uint timestamp, uint256[NUMBER_OF_TOKENS] memory quantityIn, uint256[NUMBER_OF_TOKENS] memory quantityOut, address tokenIn) {
        require(index < purchaseData.length, "[smartInvest] getPurchaseData : there is no data at this location");
        
        return (purchaseData[index].timestamp, purchaseData[index].quantityIn, purchaseData[index].quantityOut, purchaseData[index].swapToken);
    }

    /*
     * getSaleData : returns the sale data according to a given index (index that can be retrieved with the getSaleIndex function)
     */
    function getSaleData(uint256 index) public view returns (uint timestamp, uint256[NUMBER_OF_TOKENS] memory quantityIn, uint256[NUMBER_OF_TOKENS] memory quantityOut, address tokenOut) {
        require(index < saleData.length, "[smartInvest] getSaleData : there is no data at this location");
        
        return (saleData[index].timestamp, saleData[index].quantityIn, saleData[index].quantityOut, saleData[index].swapToken);
    }

    /*
     * setRouter : to change the router's address
     */
    function setRouter(address newRouter) public {
        require(paused == true, "[smartInvest] setRouter : the contract must be paused");
        require(msg.sender == admin, "[smartInvest] setRouter : only admin");
        require (routerAdd != newRouter, "[smartInvest] setRouter : the router address already has this value");
        routerAdd = newRouter;
        pancakeSwapRouter = IPancakeRouter02(routerAdd);
    }

    receive() external payable virtual {}           /// To recieve WBNB from pancakeSwapRouter when swaping
}