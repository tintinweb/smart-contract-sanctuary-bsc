// SPDX-License-Identifier: UNLICENSED
// (c) Oleksii Vynogradov 2021, All rights reserved, contact a[email protected] if you like to use code
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IOracle.sol";
import "./IOpenBiSeaAuction.sol";

interface IOpenBiSeaInt {
    function bid(
        address contractNFT,
        uint256 tokenId,
        bool isERC1155,
        address referral
    ) external payable;
}


contract OpenBiSea is Ownable  {
    using SafeMath for uint256;

    address public auction;
    address public usdContract;
    address public tokenOBS;
    uint256 public rate;
    uint256 public auctionCreationFeeMultiplier = 1;
    uint256 public auctionContractFeeMultiplier;
    uint256 public totalIncome;
    uint256 public tokensaleTotalSold;
    uint256 public platformFeePercent = 5;
    uint256 public referralPercent = 2;
    IOracle _oracleContract;

    mapping(address => address) private _referrals;

    mapping(address => bool) public restrictedTokens;

    uint256 public initialBalance;

    uint256 public initialPrice = 0.0888 ether;
    uint256 public mainCoinToUSD = 472 ether;
    // 88800000000000000 - 0.0888 BNB one token, 607578947368421000 - MATIC one token, 14697931034482762 - METIS,
    // 14145132743363000 - Aurora(ETH), 55956229793583686000 - Cronos(CRO), KAVA - 7668711656441718000 (KAVA). 428689655172413952 - Avalanche(AVAX)

    constructor (
        uint256 _initialBalance,
        address _usdContract,
        address _tokenOBS,
        uint256 _initialPrice,
        uint256 _mainCoinToUSD,
        uint256 _networkId
    ) {
        tokenOBS = _tokenOBS;
        initialBalance = _initialBalance;
        usdContract = _usdContract;
        initialPrice = _initialPrice;
        mainCoinToUSD = _mainCoinToUSD;

        if (_networkId == 56) {
            tokensaleTotalSold = 429.2125438496257 ether;
        }
        if (_networkId == 97) {
            tokensaleTotalSold = 429.2125438496257 ether;
        }
    }

    function setOracleContract(IOracle _oracle) public onlyOwner {
        _oracleContract = _oracle;
    }

    function getReferral(address buyer) public view returns (address) {
        return _referrals[buyer];
    }

    function getMainCoinToUSD() public view returns (uint256) {
        return mainCoinToUSD;
    }

    function getTokenOBS() public view returns (address) {
        return tokenOBS;
    }

    function getInitialBalance() public view returns (uint256) {
        return initialBalance;
    }

    function getTokensaleTotalSold() public view returns (uint256) {
        return tokensaleTotalSold;
    }

    function getOracleContract() public view returns (IOracle) {
        return _oracleContract;
    }

    function _setRestrictedToken(address token, bool isRestricted) public onlyOwner {
        restrictedTokens[token] = isRestricted;
    }

    function _setReferral(address buyer, address referral) public onlyOwner {
        _referrals[buyer] = referral;
    }

    function _setPremiumFee(uint256 _premiumFee) public onlyOwner {
        platformFeePercent = _premiumFee;
    }

    function _setReferralPercent(uint256 _referralPercent) public onlyOwner {
        referralPercent = _referralPercent;
    }

    function _withdrawSuperAdmin(address payable sender,address token, uint256 amount) public onlyOwner returns (bool) {
        if (amount > 0) {
            if (token == address(0)) {
                (bool success, ) = sender.call{value:amount}("");
                require(success, "OpenBiSea: Transfer failed.");
                return true;
            } else {
                IERC20(token).transfer(sender, amount);
                return true;
            }
        }
        return false;
    }

    function _setRate(uint256 _rate) public onlyOwner {
        rate = _rate;
    }

    function _setAuction(address _auction) public onlyOwner {
        auction = _auction;
    }

    function getInitialPriceInt() public view returns (uint256)  {
        return initialPrice;
    }

    function setInitialPriceInt(uint256 _initialPriceInt) public onlyOwner {
        initialPrice = _initialPriceInt;
    }

    function setUsdContract(address _usdContract) public onlyOwner {
        usdContract = _usdContract;
    }

    function getUsdContract() public view returns (address)  {
        return usdContract;
    }

    function purchaseTokensQuantityFor(uint256 amount) public view returns (uint256,uint256) {
        uint256 delta = initialBalance.sub(tokensaleTotalSold);
        uint256 newPrice = initialPrice.mul(initialBalance).div(delta);
        return (amount.mul(10 ** uint256(18)).div(newPrice),initialBalance.sub(tokensaleTotalSold));
    }

    function purchaseTokens(address referral) public payable returns (uint256) {
        require(msg.value > 1000000000000000, "OpenBiSea: minimal purchase 0.001");
        uint256 amountTokens;
        uint256 balance;
        (amountTokens,balance) = purchaseTokensQuantityFor(msg.value);
        require(amountTokens > 0, "OpenBiSea: we can't sell 0 tokens.");
        require(amountTokens < balance.div(3), "OpenBiSea: we can't sell more than 30% from one transaction. Please decrease investment amount.");
        if (referral != address (0x0)) {
            uint256 referralFee = msg.value.mul(referralPercent).div(100);
            _referrals[msg.sender] = referral;
            bool success;
            (success, ) = referral.call{value:referralFee}("");
            require(success, "OpenBiSea: Transfer failed.");
            (success, ) = owner().call{value:msg.value.sub(referralFee)}("");
            require(success, "OpenBiSea: Transfer failed.");

        } else {
            (bool success, ) = owner().call{value:msg.value}("");
            require(success, "OpenBiSea: Transfer failed.");
        }

        IERC20(tokenOBS).transfer(msg.sender, amountTokens);
        tokensaleTotalSold = tokensaleTotalSold.add(amountTokens);

        return amountTokens;
    }

    function contractsNFTWhitelisted() public view returns (address[] memory) {
        return IOpenBiSeaAuction(auction).contractsNFTWhitelisted();
    }

    function whitelistContractCreator(address _contractNFT) public payable {
        require(msg.value >= initialPrice.mul(auctionCreationFeeMultiplier), "OpenBiSea: you must send minimal amount or more");
        (bool success, ) = owner().call{value:msg.value}("");
        require(success, "OpenBiSea: Transfer failed.");

        IOpenBiSeaAuction(auction).whitelistContractCreator(_contractNFT,msg.value);
        totalIncome = totalIncome.add(msg.value);
    }

    function whitelistContractCreatorTokens(address _contractNFT) public {
        uint256 amount = (10 ** uint256(18)).mul(auctionCreationFeeMultiplier);
        IERC20(tokenOBS).transferFrom(msg.sender,address(this),amount);
        totalIncome = totalIncome.add(initialPrice.mul(amount).div(10 ** uint256(18)));
        IOpenBiSeaAuction(auction).whitelistContractCreator(_contractNFT, initialPrice.mul(amount));
    }


    function createAuction(
        address _contractNFT,
        uint256 _tokenId,
        uint256 _price,
        uint256 _deadline,
        bool _isERC1155,
        address token
    ) public {
        require(restrictedTokens[token] != true, "OpenBiSea: token is restricted for auctions");
        IOpenBiSeaAuction(auction).createAuction(_contractNFT,_tokenId, _price, _deadline,_isERC1155, msg.sender, token);
    }

    struct AuctionResult {
        bool isWin;
        uint256 amountTransferBack;
        address auctionLatestBidderOrSeller;
        address tokenSaved;
    }

    function bidToken(
        address contractNFT,
        uint256 tokenId,
        uint256 bidAmount,
        bool isERC1155,
        address referral,
        address token
    ) public {
        require(restrictedTokens[token] != true, "OpenBiSea: token is restricted for auctions");
        IERC20(token).transferFrom(msg.sender,address(this), bidAmount);
        bool isWin;
        uint256 amountTransferBack;
        address auctionLatestBidderOrSeller;
        address tokenSaved;
        (isWin, amountTransferBack, auctionLatestBidderOrSeller, tokenSaved) = IOpenBiSeaAuction(auction).bid( contractNFT, tokenId, bidAmount, isERC1155, msg.sender, token);
        require(token == tokenSaved, "OpenBiSea: auction use another token");

        if (isWin) {
            uint256 depositFee = bidAmount.mul(platformFeePercent).div(100);
            uint256 depositFeeReferrer = bidAmount.mul(referralPercent).div(100);
            uint256 totalSellerAmount = bidAmount.sub(depositFee);
            if (_referrals[msg.sender] != address(0) || referral != address(0)) {
                if (referral != address(0)) {
                    _referrals[msg.sender] = referral;
                }
                totalSellerAmount = totalSellerAmount.sub(depositFeeReferrer);
                IERC20(token).transfer(_referrals[msg.sender],depositFeeReferrer);
                IERC20(token).transfer(owner(),depositFee);
            } else {
                IERC20(token).transfer(owner(),depositFee);
            }
            IERC20(token).transfer(auctionLatestBidderOrSeller,totalSellerAmount);
        } else {
            if (amountTransferBack > 0) {
                IERC20(token).transfer(auctionLatestBidderOrSeller,amountTransferBack);
            }
        }
    }

    function bidTokenBatch(
        address[] memory contractsNFT,
        uint256[] memory tokenIds,
        uint256[] memory bidAmounts,
        bool [] memory isERC1155s,
        address[] memory referrals,
        address[] memory tokens) public{
        for (uint i=0; i< contractsNFT.length; i++) {
            bidToken(contractsNFT[i],tokenIds[i],bidAmounts[i],isERC1155s[i],referrals[i],tokens[i]);
        }
    }


    function bid(
        address contractNFT,
        uint256 tokenId,
        bool isERC1155,
        address referral
    ) public payable {
        bool isWin;
        uint256 amountTransferBack;
        address auctionLatestBidderOrSeller;
        address token;
        (isWin,amountTransferBack,auctionLatestBidderOrSeller,token) = IOpenBiSeaAuction(auction).bid( contractNFT, tokenId, msg.value, isERC1155, msg.sender, address (0x0) );
        require(token == address (0x0), "OpenBiSea: auction must use main coin");
        bool success;

        if (isWin) {
            uint256 depositFee = msg.value.mul(platformFeePercent).div(100);
            uint256 depositFeeReferrer = msg.value.mul(referralPercent).div(100);
            uint256 totalSellerAmount = msg.value.sub(depositFee);

            if (_referrals[msg.sender] != address(0) || referral != address(0)) {
                if (referral != address(0)) {
                    _referrals[msg.sender] = referral;
                }
                totalSellerAmount = totalSellerAmount.sub(depositFeeReferrer);
                (success, ) = _referrals[msg.sender].call{value:depositFeeReferrer}("");
                require(success, "OpenBiSea: Transfer failed.");
                (success, ) = owner().call{value:depositFee}("");
                require(success, "OpenBiSea: Transfer failed.");
            } else {
                (success, ) = owner().call{value:depositFee}("");
                require(success, "OpenBiSea: Transfer failed.");
            }
            (success, ) = auctionLatestBidderOrSeller.call{value:totalSellerAmount}("");
            require(success, "OpenBiSea: Transfer failed.");
        } else {
            if (amountTransferBack > 0) {
                (success, ) = auctionLatestBidderOrSeller.call{value:amountTransferBack}("");
                require(success, "OpenBiSea: Transfer failed.");
            }
        }
    }

    function bidBatch(
        address[] memory contractsNFT,
        uint256[] memory tokenIds,
        uint256[] memory bidAmounts,
        bool [] memory isERC1155s,
        address[] memory referrals
    ) public payable {
        for (uint i=0; i< contractsNFT.length; i++) {
            IOpenBiSeaInt(address(this)).bid{value:bidAmounts[i]}(contractsNFT[i],tokenIds[i],isERC1155s[i],referrals[i]);
        }
    }

    function cancelAuction( address _contractNFT, uint256 _tokenId, bool _isERC1155) public {
        IOpenBiSeaAuction(auction).cancelAuction(_contractNFT,_tokenId,msg.sender,_isERC1155);
    }


    function checkTokensForClaim( address customer, uint256 priceMainToUSD) public view returns (uint256,uint256,uint256,bool) {
        return IOpenBiSeaAuction(auction).checkTokensForClaim(customer,priceMainToUSD);
    }


    event ClaimFreeTokens(uint256 amount, address investor);//, uint256 amountTotalUSDwei, uint256 incomeInOBSfromUser, uint256 percentOfSales, uint256 newPriceOBS, uint256 priceMainToUSD);

    function claimFreeTokens() public returns (bool, uint256, uint256, uint256, uint256, uint256) {
        uint256 priceMainToUSD;
        uint8 decimals;
        if (_oracleContract.getIsOracle()) (priceMainToUSD,decimals) = _oracleContract.getLatestPrice();
        else {
            priceMainToUSD = mainCoinToUSD;
            decimals = 18;
        }

        uint256 tokensToPay;
        uint256 amountTotalForCustomerUSDwei;
        uint256 percentOfSales;

        (tokensToPay, amountTotalForCustomerUSDwei, percentOfSales,)= checkTokensForClaim(msg.sender,priceMainToUSD.div(10 ** uint256(decimals)));
        uint256 delta = initialBalance.sub(tokensaleTotalSold);
        uint256 newPriceOBS = initialPrice.mul(initialBalance).div(delta);
//        uint256 usdPriceOBS = newPriceOBS.mul(priceMainToUSD).div(10 ** decimals);
        uint256 incomeInOBSfromUser = (amountTotalForCustomerUSDwei * (10 ** decimals) * percentOfSales) / (priceMainToUSD * newPriceOBS * 10000);
        uint256 tokensToPayFinal = tokensToPay;

        if (tokensToPay > incomeInOBSfromUser) tokensToPayFinal = incomeInOBSfromUser / 100; // can't reward more than 1% of customer income

        bool result = false;
        if (tokensToPayFinal > 0) {
            IERC20(tokenOBS).transfer(msg.sender, tokensToPayFinal);
            IOpenBiSeaAuction(auction).setConsumersReceivedMainTokenLatestDate(msg.sender);
            result = true;
        }
        emit ClaimFreeTokens(tokensToPayFinal, msg.sender);//, amountTotalForCustomerUSDwei, incomeInOBSfromUser, percentOfSales, newPriceOBS, priceMainToUSD);
        return (result, amountTotalForCustomerUSDwei, incomeInOBSfromUser, newPriceOBS, priceMainToUSD, tokensToPay);
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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

// SPDX-License-Identifier: UNLICENSED
// (c) Oleksii Vynogradov 2021, All rights reserved, contact [email protected] if you like to use code
pragma solidity ^0.8.0;
interface IOracle {
    function getLatestPrice() external view returns (uint256, uint8);
    function getIsOracle() external view returns (bool);
    function getCustomPrice(address aggregator) external view returns (uint256, uint8);
}

// SPDX-License-Identifier: UNLICENSED
// (c) Oleksii Vynogradov 2021, All rights reserved, contact [email protected] if you like to use code
pragma solidity ^0.8.0;
interface IOpenBiSeaAuction {
    function contractsNFTWhitelisted() external view returns (address[] memory);
    function whitelistContractCreator(address _contractNFT, uint256 fee) external payable;
    function createAuction(
        address _contractNFT,
        uint256 _tokenId,
        uint256 _price,
        uint256 _deadline,
        bool _isERC1155,
        address _sender,
        address token
    ) external;

    function bid(
        address _contractNFT,
        uint256 _tokenId,
        uint256 _price,
        bool _isERC1155,
        address _sender,
        address token
    ) external returns (bool, uint256, address, address);

    function cancelAuction(address _contractNFT, uint256 _tokenId, address _sender, bool _isERC1155) external;
    function checkTokensForClaim(address customer, uint256 priceMainToUSD) external view returns (uint256,uint256,uint256,bool);
    function setConsumersReceivedMainTokenLatestDate(address _sender) external;
}