/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: NONE
// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

// File: contracts/mlxICO.sol



pragma solidity 0.8.15;


// Part: IERC20

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// File: MilleniumSales.sol

contract MillenniumIco {
    
    bool public is_active = true;
    address public token_address;
    address public owner;
    
    uint256 public totalTokensSold = 0;
    //Token price in BNB
    uint256 public _price = 0.0003 ether;
    // Token price in USD
    uint256 public _usdPrice = 0.08 ether;
    // Price Denominator
    uint256 private _priceDenom = 100000000;
    mapping (address => uint256) public _tokenBought;
    // Token SOld
    uint256 public tokensSOLD = 0;
    uint256 public usdSold = 0;
    uint256 public bnbSold = 0;

    // Tokens to be supported
    address public busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;

    uint256 level1 = 3;
    uint256 level2 = 5;
    uint256 level3 = 10;   

    uint256 public minSaleAmount = 125e18;
    uint256 public minSaleAmountBNB = 125;

    struct referral_rewards{
        address first_user;
    }

    struct referral{
    uint amount;
    uint refFundsBNB;
    uint refFundsUSD;
    }


    mapping (address => referral) public referralRecord;

    mapping (address => referral_rewards) public refer;
    
    
    event TokensReceived(address _sender, uint256 _amount);
    event OwnershipChanged(address _new_owner);

    modifier onlyOwner() {
        require(msg.sender == owner,"Not Allowed");
        _;
    }

    event BoughtMLX(address indexed sender);

    modifier isSale(uint256 saleAmount) {
        require(is_active, "Presale is not open now");
        require(saleAmount >= minSaleAmount, "Sale amount should be more than minSaleAmount");
        _;
    }

    modifier isSaleBNB(uint256 saleAmount) {
        require(is_active, "Presale is not open now");
        require(saleAmount >= minSaleAmountBNB, "Sale amount should be more than minSaleAmount");
        _;
    }


    constructor () {
        owner = msg.sender;
        token_address = 0x7Ad0972c488B6372c6657776e6B6Ce594372CFEF;
    }

    function change_owner(address _owner) public onlyOwner() {
        owner = _owner;
        emit OwnershipChanged(_owner);
    }
    
    function setStrainsaddress(address _address) public onlyOwner() {
        token_address = _address;
    }

    function change_state() public onlyOwner() {
        is_active = !is_active;
    }


    function get_balance(address token) public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function change_price(uint256 newPrice) public onlyOwner() {
        _price = newPrice;
    }

    function change_minSaleAmount(uint256 saleMin) public onlyOwner() {
        minSaleAmount = saleMin;
    }

    function changUsdPrice(uint256 _newUsdPrice) public onlyOwner() {
        _usdPrice = _newUsdPrice;
    }

    function getBUSDSaleAmount(uint256 baseAmount) public view returns (uint256 busdAmount) {
        busdAmount = (_usdPrice * baseAmount) / 10 ** 18;
    }

    function buyMlx(address _ref, uint256 amount) public payable isSaleBNB(amount) {
        uint256 totalBought = amount * _price;
        require(msg.value >= totalBought, "Insufficient amount");

        IERC20 token = IERC20(token_address);
        uint256 decimal_multiplier = (10 ** token.decimals());
        uint256 tokensToSend = amount * decimal_multiplier;
        address lvl3 = refer[_ref].first_user;

                if(_ref!=address(0)){
                    if(refer[msg.sender].first_user == address(0)){
	                    refer[msg.sender].first_user = _ref;
	                    uint referralTokens1 = SafeMath.mul(totalBought, level1);
                        address payable level1user = payable(refer[msg.sender].first_user);
                        level1user.transfer(SafeMath.div(referralTokens1, 100));
                        referralRecord[refer[msg.sender].first_user].amount++;
                        uint currentRefFunds = referralRecord[refer[msg.sender].first_user].refFundsBNB;
                        referralRecord[refer[msg.sender].first_user].refFundsBNB = SafeMath.div(referralTokens1, 100) + currentRefFunds;
		                    if(refer[_ref].first_user!=address(0)){
		            	        uint referralTokens2 = SafeMath.mul(totalBought, level2);
                                address payable level2user = payable(refer[_ref].first_user);
       	            		    level2user.transfer(SafeMath.div(referralTokens2, 100));
                                referralRecord[level2user].amount++;
                                address lvl2 = refer[_ref].first_user;
                                uint currentRef2Funds = referralRecord[lvl2].refFundsBNB;
                                referralRecord[lvl2].refFundsBNB = SafeMath.div(referralTokens2, 100) + currentRef2Funds;
		            		        if(refer[lvl3].first_user!=address(0)){
		            		            uint referralTokens3 = SafeMath.mul(totalBought, level3);
                                        address payable level3user = payable(refer[lvl3].first_user);
       	            			        level3user.transfer(SafeMath.div(referralTokens3, 100));
                                        referralRecord[refer[lvl3].first_user].amount++;
                                        uint currentRefFunds3 = referralRecord[refer[lvl3].first_user].refFundsBNB;
                                        referralRecord[refer[lvl3].first_user].refFundsBNB = SafeMath.div(referralTokens3, 100) + currentRefFunds3;
				                    }
		                    }
                    }
                }

        require(token.balanceOf(address(this)) >= tokensToSend, "Insufficient Tokens in stock");
        token.transfer(msg.sender, tokensToSend);
        emit BoughtMLX(msg.sender);
    }
    
    function buyMLXwithTokens(address _ref, address tokentoBuy, uint256 tokenAmount) external isSale(tokenAmount) {
        IERC20 token = IERC20(token_address);
        uint256 tokensToSend = tokenAmount;
       
        if(tokentoBuy == busd) {
            uint256 busdAmount = getBUSDSaleAmount(tokenAmount);
            IERC20 _busdToken = IERC20(busd);
            uint256 tokensToReceive = busdAmount;

            require(_busdToken.balanceOf(msg.sender) >= tokensToReceive, "Insufficient Funds");
            require(token.balanceOf(address(this)) >= tokensToSend, "Insufficient Tokens in stock");
           _busdToken.transferFrom(msg.sender, address(this), tokensToReceive);
           address lvl2ref = refer[_ref].first_user;

           if(_ref!=address(0)){
                    if(refer[msg.sender].first_user == address(0)){
	                    refer[msg.sender].first_user = _ref;
	                    uint referralTokens1 = SafeMath.mul(tokensToReceive, level1);
                        _busdToken.transfer(refer[msg.sender].first_user, SafeMath.div(referralTokens1, 100));
                        referralRecord[refer[msg.sender].first_user].amount++;
                        uint currentRefFunds = referralRecord[refer[msg.sender].first_user].refFundsUSD;
                        referralRecord[refer[msg.sender].first_user].refFundsUSD = SafeMath.div(referralTokens1, 100) + currentRefFunds;
		                    if(refer[_ref].first_user!=address(0)){
		            	        uint referralTokens2 = SafeMath.mul(tokensToReceive, level2);
       	            		    _busdToken.transfer(lvl2ref, SafeMath.div(referralTokens2, 100));
                                referralRecord[lvl2ref].amount++;
                                uint currentRef2Funds = referralRecord[lvl2ref].refFundsUSD;
                                referralRecord[lvl2ref].refFundsUSD = SafeMath.div(referralTokens2, 100) + currentRef2Funds;
		            		        if(refer[lvl2ref].first_user!=address(0)){
		            		            uint referralTokens3 = SafeMath.mul(tokensToReceive, level3);
       	            			        _busdToken.transfer(refer[lvl2ref].first_user, SafeMath.div(referralTokens3, 100));
                                        referralRecord[refer[lvl2ref].first_user].amount++;
                                        uint currentRefFunds3 = referralRecord[refer[lvl2ref].first_user].refFundsUSD;
                                        referralRecord[refer[lvl2ref].first_user].refFundsUSD = SafeMath.div(referralTokens3, 100) + currentRefFunds3;
				                    }
		                    }
                    }
                }

            token.transfer(msg.sender, tokensToSend);
            usdSold += tokensToSend;
            emit BoughtMLX(msg.sender);
        }
        if(tokentoBuy == usdt) {
            uint256 busdAmount = getBUSDSaleAmount(tokenAmount);
            IERC20 _usdToken = IERC20(usdt);
            uint256 tokensToReceive = busdAmount;

            require(_usdToken.balanceOf(msg.sender) >= tokensToReceive, "Insufficient Funds");
            require(token.balanceOf(address(this)) >= tokensToSend, "Insufficient Tokens in stock");
           _usdToken.transferFrom(msg.sender, address(this), tokensToReceive);
           address lvl2ref = refer[_ref].first_user;

            if(_ref!=address(0)){
                    if(refer[msg.sender].first_user == address(0)){
	                    refer[msg.sender].first_user = _ref;
	                    uint referralTokens1 = SafeMath.mul(tokensToReceive, level1);
                        _usdToken.transfer(refer[msg.sender].first_user, SafeMath.div(referralTokens1, 100));
                        referralRecord[refer[msg.sender].first_user].amount++;
                        uint currentRefFunds = referralRecord[refer[msg.sender].first_user].refFundsUSD;
                        referralRecord[refer[msg.sender].first_user].refFundsUSD = SafeMath.div(referralTokens1, 100) + currentRefFunds;
		                    if(refer[_ref].first_user!=address(0)){
		            	        uint referralTokens2 = SafeMath.mul(tokensToReceive, level2);
       	            		    _usdToken.transfer(lvl2ref, SafeMath.div(referralTokens2, 100));
                                referralRecord[lvl2ref].amount++;
                                uint currentRef2Funds = referralRecord[lvl2ref].refFundsUSD;
                                referralRecord[lvl2ref].refFundsUSD = SafeMath.div(referralTokens2, 100) + currentRef2Funds;
		            		        if(refer[lvl2ref].first_user!=address(0)){
		            		            uint referralTokens3 = SafeMath.mul(tokensToReceive, level3);
       	            			        _usdToken.transfer(refer[lvl2ref].first_user, SafeMath.div(referralTokens3, 100));
                                        referralRecord[refer[lvl2ref].first_user].amount++;
                                        uint currentRefFunds3 = referralRecord[refer[lvl2ref].first_user].refFundsUSD;
                                        referralRecord[refer[lvl2ref].first_user].refFundsUSD = SafeMath.div(referralTokens3, 100) + currentRefFunds3;
				                    }
		                    }
                    }
                }

            token.transfer(msg.sender, tokensToSend);
            usdSold += tokensToSend;
            emit BoughtMLX(msg.sender);
        }
        
    tokensSOLD += tokensToSend;
    }

    // global receive function
    receive() external payable {
        emit TokensReceived(msg.sender,msg.value);
    }    
    
    function withdraw_token(address token) public onlyOwner() {
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance > 0) {
            IERC20(token).transfer( msg.sender, balance);
        }
    } 
    function sendValueTo(address to_, uint256 value) internal {
        address payable to = payable(to_);
        (bool success, ) = to.call{value: value}("");
        require(success, "Transfer failed.");
    }
    function withdraw_bnb() public onlyOwner() {
        sendValueTo(msg.sender, address(this).balance);
    }
    
    fallback () external payable {}
    
}