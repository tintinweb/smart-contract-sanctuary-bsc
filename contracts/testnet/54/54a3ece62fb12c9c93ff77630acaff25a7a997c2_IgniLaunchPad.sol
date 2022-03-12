// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./library/LaunchPadValidations.sol";
import "./interface/IIgniNFT.sol";
import "./interface/IUniswapV2Router.sol";
import "./interface/IIgniLaunchPad.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract BurnableContract {
    // This doesn't have to match the real contract name. Call it what you like.
    function burn(uint256 amount) external virtual returns (bool);
}

/**
 * @notice IgniToken is a development token that we use to learn how to code solidity
 * and what BEP-20 interface requires
 */
contract IgniLaunchPad is
    Ownable,
    ReentrancyGuard,
    IIgniLaunchPad,
    LaunchPadValidations
{
    using SafeMath for uint256;
    uint256 MAX_INT = 2**256 - 1;
    address public _fundsWallet;

    event IdoAdded(
        uint256 idoId,
        Ido idoData,
        uint256 hardCapFounders,
        uint256 foundersEndTime
    );
    event IdoFill(uint256 idoId, uint256 amount, uint256 totalFilled);
    event IdoWithdraw(uint256 idoId);
    event IdoClaimed(uint256 idoId);
    event IdoCancelledStatus(uint256 idoId, bool newStatus);

    constructor() {
        _fundsWallet = msg.sender;
    }

    function setFundsWallet(address fundsWallet) public onlyGovernance {
        _fundsWallet = fundsWallet;
    }

    function emergencyWithdrawGm(uint256 amount, address payable sendTo)
        external
        onlyGovernance
    {
        sendTo.transfer(amount);
    }

    function emergencyTransferGm(
        uint256 idoId,
        uint256 amount,
        address payable sendTo
    ) external onlyGovernance {
        Ido storage currentIdo = currentIdos[idoId];
        IERC20 tokenContract = IERC20(currentIdo.tokenAddress);
        tokenContract.transferFrom(address(this), sendTo, amount);
    }

    // Igni cancel IDO without transfer
    function emergencyCancelIdoGm(uint256 idoId)
        external
        onlyGovernance
        validHasNotLiqAdded(idoId)
    {
        currentIdosExtra[idoId].isCancelled = true;
        emit IdoCancelledStatus(idoId, currentIdosExtra[idoId].isCancelled);
    }

    function emergencyWithdraw(uint256 idoId)
        external
        nonReentrant
        validWithdrawIdoCancelled(idoId)
        validHasPurchase(idoId)
        validHasWithdraw(idoId)
        validHasClaim(idoId)
        validWithdrawLidAdded(idoId)
    {
        // `Ido storage currentIdo = currentIdos[idoId];
        IdoExtra storage currentIdoExtra = currentIdosExtra[idoId];

        currentIdoExtra.withdrawByWallet[msg.sender] = true;
        payable(msg.sender).transfer(currentIdoExtra.buyByWallet[msg.sender]);

        emit IdoWithdraw(idoId);
    }

    function canClaimIdo(uint256 idoId)
        public
        view
        validIdoIsNotCancelled(idoId)
        validHasPurchase(idoId)
        validHasWithdraw(idoId)
        validHasClaim(idoId)
        validHasLiqAdded(idoId)
        returns (bool)
    {
        Ido storage currentIdo = currentIdos[idoId];
        IdoExtra storage currentIdoExtra = currentIdosExtra[idoId];
        // only  successful ido
        require(
            currentIdoExtra.amountFilled >= currentIdo.softCap,
            "only successful IDO"
        );
        return true;
    }

    function claimIdo(uint256 idoId)
        external
        nonReentrant
        validIdoIsNotCancelled(idoId)
        validSaleEndTimePass(idoId)
        validHasPurchase(idoId)
        validHasWithdraw(idoId)
        validHasClaim(idoId)
        validSoftCapFilled(idoId)
        validHasLiqAdded(idoId)
    {
        Ido storage currentIdo = currentIdos[idoId];
        IdoExtra storage currentIdoExtra = currentIdosExtra[idoId];

        currentIdoExtra.claimByWallet[msg.sender] = true;
        uint256 tksAmount = currentIdoExtra
            .buyByWallet[msg.sender]
            .mul(currentIdo.tokenRatePresale)
            .div(10**18);
        IERC20 tokenContract = IERC20(currentIdo.tokenAddress);
        tokenContract.transferFrom(address(this), msg.sender, tksAmount);

        emit IdoClaimed(idoId);
    }

    // In some liquidity emergency the owner can release the difference
    function setLiqAdded(uint256 idoId, bool value) external onlyGovernance {
        IdoExtra storage currentIdoExtra = currentIdosExtra[idoId];
        currentIdoExtra.lqAdded = value;
    }

    // Calculates the tokens that need to be returned or burned from the ICO
    function _getUnsoldAmountTokens(uint256 idoId)
        public
        view
        returns (uint256)
    {
        Ido storage currentIdo = currentIdos[idoId];
        uint256 totalTks = _getAmountTokensIdos(currentIdo);
        IdoExtra storage currentIdoExtra = currentIdosExtra[idoId];
        uint256 diffUnsold = currentIdo.hardCap.sub(
            currentIdoExtra.amountFilled
        );
        uint256 percentUnfilled = diffUnsold
            .mul(10**18)
            .div(currentIdo.hardCap)
            .div(10**16);
        return percentUnfilled.mul(totalTks).div(10**2);
    }

    function burnOrClaimUnsoldDevTokens(uint256 idoId, bool useBurnCall)
        external
        nonReentrant
        validOnlyIdoOwner(idoId)
        validIdoIsNotCancelled(idoId)
        validSoftCapFilled(idoId)
        validSaleEndTimePass(idoId)
        validHasLiqAdded(idoId)
    {
        Ido storage currentIdo = currentIdos[idoId];
        IdoExtra storage currentIdoExtra = currentIdosExtra[idoId];
        require(
            currentIdoExtra.diffSentOwner == false,
            "Diff IDO already sent"
        );
        currentIdoExtra.diffSentOwner = true;
        uint256 valueToLq = currentIdoExtra
            .amountFilled
            .mul(currentIdo.percToLq * 10**16)
            .div(10**18);
        uint256 diffLiqToOwner = currentIdoExtra.amountFilled.sub(valueToLq);
        // Send the difference that was not going to liquidity to IDO's owner
        payable(currentIdo.owner).transfer(diffLiqToOwner);
        // Return or burning of non-traded values
        IERC20 tokenContract = IERC20(currentIdo.tokenAddress);
        uint256 unsoldAmount = _getUnsoldAmountTokens(idoId);

        if (unsoldAmount == 0) return;

        if (currentIdoExtra.refundNotSoldToken) {
            address destTokens = currentIdo.owner;
            tokenContract.transferFrom(address(this), destTokens, unsoldAmount);
        } else {
            if (useBurnCall) {
                BurnableContract(currentIdo.tokenAddress).burn(unsoldAmount);
            } else {
                tokenContract.transferFrom(
                    address(this),
                    0x000000000000000000000000000000000000dEaD,
                    unsoldAmount
                );
            }
        }
    }

    function addLiquidity(uint256 idoId)
        external
        nonReentrant
        validOnlyIdoOwner(idoId)
        validHasNotLiqAdded(idoId)
        validIdoIsNotCancelled(idoId)
    {
        Ido storage currentIdo = currentIdos[idoId];
        IdoExtra storage currentIdoExtra = currentIdosExtra[idoId];

        // only  successful ido
        require(
            currentIdoExtra.amountFilled >= currentIdo.hardCap ||
                (currentIdoExtra.amountFilled >= currentIdo.softCap &&
                    block.timestamp >= currentIdo.saleEndTime),
            "only successful IDO"
        );

        address routerAddress = _routerList[currentIdoExtra.routerDeploy];
        require(routerAddress != address(0), "Set the router address");

        //  // approve token transfer to cover all possible scenarios
        // _approve(address(this), address(uniswapV2Router), tokenAmount);
        IUniswapV2Router _uniswapV2Router = IUniswapV2Router(routerAddress); //BUB: 0x10 address is pancakeSwapV2 mainnet router //0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3

        uint256 percLq = currentIdo.percToLq * 10**16;
        uint256 valueToLq = currentIdoExtra.amountFilled.mul(percLq).div(
            10**18
        );

        uint256 valueTokens = valueToLq.mul(currentIdo.tokenRateListing).div(
            10**18
        ); // calculates total tokens for liquidity

        {
            // avoid too deep error
            IERC20 tokenContract = IERC20(currentIdo.tokenAddress);
            tokenContract.approve(routerAddress, MAX_INT);
        }

        // add the liquidity
        _uniswapV2Router.addLiquidityETH{value: valueToLq}(
            currentIdo.tokenAddress,
            valueTokens,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            currentIdo.owner,
            block.timestamp
        );

        currentIdoExtra.lqAdded = true;
    }

    function addItemsToWhiteList(address[] memory addresses, uint256 idoId)
        external
        nonReentrant
        validOnlyIdoOwner(idoId)
    {
        IdoExtra storage currentIdoExtra = currentIdosExtra[idoId];
        for (uint256 i = 0; i < addresses.length; i++) {
            currentIdoExtra.whiteList.push(addresses[i]);
        }
    }

    function createIdo(Ido memory idoData)
        public
        payable
        nonReentrant
        validCreateCorrectAmount(idoData)
        validCreateBalanceAmount(idoData)
        validCreateLiquidity(idoData)
    {
        _idoId++;
        idoData.owner = msg.sender;

        uint256 tksAmount = _getAmountTokensIdos(idoData);
        IERC20 tokenContract = IERC20(idoData.tokenAddress);

        tokenContract.transferFrom(msg.sender, address(this), tksAmount);
        tokenContract.approve(address(this), MAX_INT);

        require(
            tokenContract.balanceOf(address(this)) >= tksAmount,
            "disable fee for IDO contract"
        );

        currentIdos[_idoId] = idoData;
        IdoExtra storage currentIdoExtra = currentIdosExtra[_idoId];

        currentIdoExtra.foundersEndTime =
            idoData.saleStartTime +
            (_minRoundFounders * 1 minutes);

        currentIdoExtra.hardCapFounders = idoData
            .hardCap
            .mul(_percCapForFounder)
            .div(10**18);

        payable(_fundsWallet).transfer(msg.value);

        emit IdoAdded(
            _idoId,
            idoData,
            currentIdoExtra.hardCapFounders,
            currentIdoExtra.foundersEndTime
        );
    }

    function contribute(uint256 idoId)
        public
        payable
        nonReentrant
        validSaleClosed(idoId)
        validCanContrib(idoId)
        validBuyMaxAllowed(idoId)
        validBuyMinAllowed(idoId)
        validMaxHardCap(idoId)
        validMaxHardCapOnFounders(idoId)
        validIdoIsNotCancelled(idoId)
        validHasNotLiqAdded(idoId)
    {
        IdoExtra storage currentIdoExtra = currentIdosExtra[idoId];

        currentIdoExtra.buyByWallet[msg.sender] += msg.value;
        currentIdoExtra.amountFilled += msg.value;

        emit IdoFill(idoId, msg.value, currentIdoExtra.amountFilled);
    }

    function cancelIdo(uint256 idoId)
        external
        nonReentrant
        validOnlyIdoOwner(idoId)
        validHasNotLiqAdded(idoId)
        validIdoIsNotCancelled(idoId)
    {
        currentIdosExtra[idoId].isCancelled = true;
        Ido storage currentIdo = currentIdos[idoId];
        uint256 tksAmount = _getAmountTokensIdos(currentIdo);
        IERC20 tokenContract = IERC20(currentIdo.tokenAddress);
        tokenContract.transferFrom(address(this), currentIdo.owner, tksAmount);
        emit IdoCancelledStatus(idoId, currentIdosExtra[idoId].isCancelled);
    }

    function changeDateIdo(
        uint256 idoId,
        uint256 saleStartTime,
        uint256 saleEndTime
    )
        external
        nonReentrant
        validOnlyIdoOwner(idoId)
        validIdoIsNotCancelled(idoId)
    {
        Ido storage currentIdo = currentIdos[idoId];
        require(
            block.timestamp < currentIdo.saleStartTime ||
                msg.sender == _governance,
            "You cannot change the date of an IDO that has already started"
        );
        currentIdo.saleStartTime = saleStartTime;
        currentIdo.saleEndTime = saleEndTime;
        currentIdosExtra[idoId].foundersEndTime =
            currentIdo.saleStartTime +
            (_minRoundFounders * 1 minutes);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./LaunchPadBaseData.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract LaunchPadValidations is LaunchPadBaseData { 
    using SafeMath for uint256;

    /* ##############  BEGIN VALIDATIONS USED IN IDO CREATION  ################## */
    modifier validCreateCorrectAmount(Ido memory idoData) {
        require(msg.value == _idoCost[idoData.package] && msg.value > 0, "Pay correct amount for IDO");
        _;
    }
    modifier validCreateBalanceAmount(Ido memory idoData) {
        uint256 tksAmount = _getAmountTokensIdos(idoData);
        IERC20 tokenContract = IERC20(idoData.tokenAddress);
        require(
            tokenContract.balanceOf(msg.sender) >= tksAmount,
            "You need the total tokens to start the ICO in your wallet"
        );
        _;
    }
    modifier validCreateLiquidity(Ido memory idoData) {
        require(
            idoData.percToLq >= 50,
            "The liquidity percentage must be equal or higher than 50%."
        );
        require(
            idoData.percToLq <= 100,
            "The liquidity percentage must be equal to or less than 100%."
        );
        _;
    }
    /* ############## END VALIDATIONS USED IN IDO CREATION  ################## */

    /* ############## BEGIN VALIDATIONS USED ON CONTRIBUTE ################## */
    modifier validCanContrib(uint256 idoId) {
        require(
            _canContribute(idoId, msg.sender),
            "The sale is not started yet for this IDO"
        );
        _;
    }
    modifier validSaleClosed(uint256 idoId) {
        require(
            block.timestamp <= currentIdo(idoId).saleEndTime,
            "The sale is closed for this IDO"
        );
        _;
    }
    modifier validBuyMaxAllowed(uint256 idoId) {
        require(
            currentIdoExtra(idoId).buyByWallet[msg.sender] + msg.value <=
                currentIdo(idoId).maxBuy,
            "You cannot buy more than the maximum allowed"
        ); // solhint-disable;
        _;
    }
    modifier validBuyMinAllowed(uint256 idoId) {
        require(
            msg.value >= currentIdo(idoId).minBuy,
            "You cannot buy less than the minimum allowed"
        ); // solhint-disable;
        _;
    }
    modifier validMaxHardCap(uint256 idoId) {
        if (block.timestamp >= currentIdoExtra(idoId).foundersEndTime) {
            require(
                currentIdoExtra(idoId).amountFilled + msg.value <=
                    currentIdo(idoId).hardCap,
                "Your purchase exceeds the hardCap of this IDO"
            );
        }
        _;
    }
    modifier validMaxHardCapOnFounders(uint256 idoId) {
        if (block.timestamp < currentIdoExtra(idoId).foundersEndTime) {
            require(
                currentIdoExtra(idoId).amountFilled + msg.value <=
                    currentIdoExtra(idoId).hardCapFounders,
                "Your purchase exceeds the hardCap of this IDO on founders round"
            );
        }
        _;
    }
    /* ############## END VALIDATIONS USED ON CONTRIBUTE ################## */

    /* ############## BEGIN OF SHARED VALIDATIONS BETWEEN: CLAIM, WITHDRAW ################## */
    modifier validIdoIsNotCancelled(uint256 idoId) {
        require(
            !currentIdoExtra(idoId).isCancelled,
            "This IDO has been cancelled, you cannot use this function"
        );
        _;
    }
    modifier validHasPurchase(uint256 idoId) {
        require(
            currentIdoExtra(idoId).buyByWallet[msg.sender] > 0,
            "You have no purchase on this IDO"
        );
        _;
    }
    modifier validHasWithdraw(uint256 idoId) {
        require(
            !currentIdoExtra(idoId).withdrawByWallet[msg.sender],
            "You have already withdrawn this token"
        );
        _;
    }
    modifier validHasClaim(uint256 idoId) {
        require(
            !currentIdoExtra(idoId).claimByWallet[msg.sender],
            "You have already claimed this token"
        );
        _;
    }
    modifier validSoftCapFilled(uint256 idoId) {
        require(
            currentIdoExtra(idoId).amountFilled >= currentIdo(idoId).softCap,
            "This IDO has not reached the minimum softcap value to use this function"
        );
        _;
    }
    modifier validHasLiqAdded(uint256 idoId) {
        require(
            currentIdoExtra(idoId).lqAdded,
            "This IDO need liquidity before use this function"
        );
        _;
    }
    modifier validHasNotLiqAdded(uint256 idoId) {
        require(
            !currentIdoExtra(idoId).lqAdded,
            "This IDO cant has liquidity before use this function"
        );
        _;
    }
    modifier validSaleEndTimePass(uint256 idoId) {
        require(
            block.timestamp >= currentIdo(idoId).saleEndTime,
            "You need to wait IDO endtime to use this function"
        );
        _;
    }
    modifier validWithdrawIdoCancelled(uint256 idoId) {
        require(
            (currentIdoExtra(idoId).amountFilled < currentIdo(idoId).softCap && // Only if you did not fill softcap
                block.timestamp >= currentIdo(idoId).saleEndTime) ||
                currentIdoExtra(idoId).isCancelled,
            "You need to wait presale endtime to withdraw or owner cancel"
        );
        _;
    } 
    modifier validWithdrawLidAdded(uint256 idoId) {
        require(
            !currentIdoExtra(idoId).lqAdded,
            "You cannot withdraw from an ICO that has been finalized"
        );
        _;
    }

    /* ############## END OF SHARED VALIDATIONS BETWEEN: CLAIM, WITHDRAW ################## */

    /** SHARED */

    modifier validOnlyIdoOwner(uint256 idoId) {
        require(
            currentIdo(idoId).owner == msg.sender || msg.sender == _governance, // In some extreme case Igni may need to manage the IDO contract, such as cancellation of some suspect IDO
            "Only owner can use this function"
        );
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Governance {
    address public _governance;

    constructor() {
        _governance = tx.origin;
    }

    event GovernanceTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    modifier onlyGovernance() {
        require(msg.sender == _governance, "not governance");
        _;
    }

    function setGovernance(address governance) public onlyGovernance {
        require(governance != address(0), "new governance the zero address");
        emit GovernanceTransferred(_governance, governance);
        _governance = governance;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.10;

interface IUniswapV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

//

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

pragma experimental ABIEncoderV2;

import "../interface/IIgniNFT.sol";
import "../interface/IIgniNFTChangeble.sol";

interface IIgniNFTFactory {
    function getNft(uint256 tokenId)
        external
        view
        returns (IIgniNFT.Nft memory);

    function getNftTier(uint256 tokenId) external view returns (uint256);

    function getNftStruct(uint256 tokenId)
        external
        view
        returns (IIgniNFT.Nft memory nft);

    function isRulerProxyContract(address proxy) external view returns (bool);

    function changeNftData(
        uint256 tokenId,
        IIgniNFTChangeble.NFtDataChangeble calldata nftData
    ) external;

    function mintReserve(uint256 ruleId, address recipient) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


interface IIgniNFTChangeble {
    struct NFtDataChangeble {
        address owner;  // Maintains the owner when the nft is sent to contract for sale or stake
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IIgniNFT is IERC721 {
    struct Nft {
        uint256 id;
        uint256 tier;
        uint256 quality;
        address owner;
        uint256 createdTime;
        uint256 blockNum;
        uint256 power; // Used to determine current stake power
        uint256 bonusPowerPct;
        uint256 totalPower;
        bool isForSale;
        uint256 salePrice;
        address referral;
    }

    function mint(address to, uint256 tokenId) external returns (bool);

    function burn(uint256 tokenId) external;

    function tokensOfOwner(address owner)
        external
        view
        returns (uint256[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IIgniLaunchPad {
  
    struct Ido {
        uint256 saleStartTime; // start sale time
        uint256 saleEndTime; // end sale time
        address owner;
        uint256 softCap;
        uint256 hardCap;
        uint256 minBuy;
        uint256 maxBuy;
        uint256 tokenRatePresale; // How many tokens per BNB in presale
        uint256 tokenRateListing; // How many tokens per BNB or BUSD in listing
        uint256 percToLq; // Percentage for liquidity
        bool useWhiteList;
        uint256 whiteListTime; // Time in seconds where only wl can buy
        address tokenAddress; // Token where the IDO will be distributed
        uint256 package; 
    }

    // Secure variables, you can never change them without going through the rules
    struct IdoExtra {
        address[] whiteList;
        mapping(address => uint256) buyByWallet;
        mapping(address => bool) claimByWallet;
        mapping(address => bool) withdrawByWallet;
        uint256 foundersEndTime;
        uint256 hardCapFounders;
        bool isCancelled;
        bool kyc;
        uint256 amountFilled;
        bool useBusd;
        bool refundNotSoldToken; // Default is burning, devolution needs to be set
        bool lqAdded;
        bool diffSentOwner;
        uint256 routerDeploy;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../interface/IIgniLaunchPad.sol";
import "../interface/IIgniNFT.sol";
import "../interface/IIgniNFTFactory.sol";
import "../library/Governance.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LaunchPadBaseData is IIgniLaunchPad, Governance {
    using SafeMath for uint256;

    mapping(uint256 => Ido) public currentIdos;
    mapping(uint256 => IdoExtra) public currentIdosExtra;
    mapping(uint256 => address) public _routerList;

    uint256 public _idoId = 0;
    uint256 public _minRoundFounders = 5; //  Time in minutes for round founders
    uint256 public _minPerTier = 1; // Min per tier
    uint256 public _percCapForFounder = 30 * 10**16; // Cap for founders round
    uint256[] public _idoCost;

    IIgniNFT public _igniNftToken;
    IIgniNFTFactory public _igniNftFactory;

    function _getBestTier(address wallet) public view returns (uint256) {
        uint256[] memory tokens = _igniNftToken.tokensOfOwner(wallet);
        uint256 tier;
        uint256 bestTier = 0;

        for (uint256 i = 0; i < tokens.length; i++) {
            tier = _igniNftFactory.getNftTier(tokens[i]);

            if (tier < bestTier || bestTier == 0) bestTier = tier;
        }
        return bestTier;
    }

    function currentIdo(uint256 idoId) internal view returns (Ido storage) {
        return currentIdos[idoId];
    }

    function currentIdoExtra(uint256 idoId)
        internal
        view
        returns (IdoExtra storage)
    {
        return currentIdosExtra[idoId];
    }

    function getWalletExtraInfo(uint256 idoId, address wallet)
        public
        view
        returns (
            uint256 buyByWallet,
            bool claimByWallet,
            bool withdrawByWallet
        )
    {
        buyByWallet = currentIdosExtra[idoId].buyByWallet[wallet];
        claimByWallet = currentIdosExtra[idoId].claimByWallet[wallet];
        withdrawByWallet = currentIdosExtra[idoId].withdrawByWallet[wallet];
    }

    /*
     * @dev set gego contract address
     */
    function setNftTokenContract(address addressTk) public onlyGovernance {
        _igniNftToken = IIgniNFT(addressTk);
    }

    function setMinRoundFounders(uint256 minRoundFounders)
        public
        onlyGovernance
    {
        _minRoundFounders = minRoundFounders;
    }

    function setPercCapForFounder(uint256 percCapForFounder)
        public
        onlyGovernance
    {
        _percCapForFounder = percCapForFounder;
    }

    function setMinPerTier(uint256 minPerTier) public onlyGovernance {
        _minPerTier = minPerTier;
    }

    function setNftFactoryContract(address addressFac) public onlyGovernance {
        _igniNftFactory = IIgniNFTFactory(addressFac);
    }

    function addRouterList(uint256 key, address routerAddress)
        public
        onlyGovernance
    {
        _routerList[key] = routerAddress;
    }

    function addIdoCost(uint256 cost) public onlyGovernance {
        _idoCost.push(cost);
    
    }

    function setIdoCost(uint256 cost, uint256 package) public onlyGovernance {
        _idoCost[package] = cost;
    }

    function _getAmountTokensIdos(Ido memory idoData)
        public
        pure
        returns (uint256)
    {
        uint256 totalHardcapTkn = idoData.hardCap.mul(idoData.tokenRatePresale);
        uint256 percLq = idoData.percToLq * 10**16;
        uint256 capLiq = idoData.hardCap.mul(percLq).div(10**18);
        uint256 totalLqTkn = capLiq.mul(idoData.tokenRateListing);

        return (totalHardcapTkn + totalLqTkn).div(10**18);
    }


    function _canContribute(uint256 idoId, address wallet)
        public
        view
        returns (bool)
    {
        if (block.timestamp > currentIdos[idoId].saleEndTime) return false;

        uint256 tier = _getBestTier(wallet);

        uint256 baseMulTier = tier > 0 ? 6 - tier : 1; // Invert tier 1 to 5, 2 to 4 if has NFT

        uint256 offset = (_minRoundFounders * 1 minutes) -
            (baseMulTier * (_minPerTier * 1 minutes));
        uint256 walletFoundersStart = currentIdos[idoId].saleStartTime + offset;

        //check caps
        if (
            block.timestamp >= currentIdosExtra[idoId].foundersEndTime &&
            currentIdosExtra[idoId].amountFilled >= currentIdos[idoId].hardCap
        ) return false;

        // Ido finished / liq added / cancelled
        if (
            currentIdosExtra[idoId].lqAdded ||
            currentIdosExtra[idoId].isCancelled
        ) return false;

        // check caps for founders rounds
        if (
            block.timestamp < currentIdosExtra[idoId].foundersEndTime &&
            currentIdosExtra[idoId].amountFilled >=
            currentIdosExtra[idoId].hardCapFounders
        ) return false;

        // max buy by wallet
        if (
            currentIdosExtra[idoId].buyByWallet[wallet] >=
            currentIdos[idoId].maxBuy
        ) return false;

        // Members who have NFT
        if (
            tier > 0 &&
            block.timestamp >= walletFoundersStart &&
            block.timestamp <= currentIdosExtra[idoId].foundersEndTime
        ) return true;

        if (currentIdos[idoId].useWhiteList) {
            uint256 wlEnd = currentIdosExtra[idoId].foundersEndTime +
                currentIdos[idoId].whiteListTime;
            // Already released to the public after whitelist
            if (block.timestamp >= wlEnd) return true;
            // After the founders' round, and is on the whitelist
            if (
                block.timestamp >= currentIdosExtra[idoId].foundersEndTime &&
                _isOnWhiteList(idoId)
            ) return true;
        } else {
            // If whitelist is disabled, sales released after nft founders round
            if (block.timestamp >= currentIdosExtra[idoId].foundersEndTime)
                return true;
        }

        return false;
    }

    function _isOnWhiteList(uint256 idoId) public view returns (bool) {
        for (uint256 i = 0; i < currentIdosExtra[idoId].whiteList.length; i++) {
            address _addressArr = currentIdosExtra[idoId].whiteList[i];
            if (_addressArr == msg.sender) {
                return true;
            }
        }
        return false;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

    constructor() {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}