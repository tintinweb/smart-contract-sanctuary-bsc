/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;


interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

interface IDaylight {
    function burnFrom(address account, uint256 amount) external returns (bool);
    function getOwner() external view returns (address);
}

contract DaylightRedeem {

    // daylight token
    address public constant daylight = 0x62529D7dE8293217C8F74d60c8C0F6481DE47f0E;

    // tokens list
    address[] public tokens;

    // redeem fee
    uint256 public redeemFee = 20;
    uint256 public constant feeDenominator = 1000;

    modifier onlyOwner() {
        require(
            msg.sender == IDaylight(daylight).getOwner(),
            'Only Daylight Owner'
        );
        _;
    }

    constructor() {
        tokens.push(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    }

    function setRedeemFee(uint256 newFee) external onlyOwner {
        require(
            newFee <= feeDenominator / 2,
            'Fee Too High'
        );
        redeemFee = newFee;
    }

    function addToken(address token) external onlyOwner {
        tokens.push(token);
    }

    function removeToken(address token) external onlyOwner {
        uint len = tokens.length;
        uint index = len;
        for (uint i = 0; i < len;) {
            
            if (tokens[i] == token) {
                index = i;
                break;
            }

            unchecked { ++i; }
        }
        require(index < len, 'Token Not Found');
        tokens[index] = tokens[tokens.length - 1];
        tokens.pop();
    }

    function redeem(uint256 amount) external {
        require(
            IERC20(daylight).allowance(msg.sender, address(this)) >= amount,
            'Insufficient Allowance'
        );

        // length of token array
        uint len = tokens.length;

        // amounts array
        uint256[] memory amounts = new uint256[](len);

        // loop through tokens, calculating amounts to redeem
        for (uint i = 0; i < len;) {
            amounts[i] = amountToRedeemWithFee(tokens[i], amount);
            unchecked { ++i; }
        }

        // burn tokens from sender
        uint totalBefore = IERC20(daylight).totalSupply();
        require(
            IDaylight(daylight).burnFrom(msg.sender, amount),
            'Error Burn From'
        );
        uint totalAfter = IERC20(daylight).totalSupply();
        require(
            ( totalBefore - totalAfter ) == amount,
            'Error Burn Calculation'
        );

        // iterate through token list, sending user their amount
        for (uint i = 0; i < len;) {
            IERC20(tokens[i]).transfer(msg.sender, amounts[i]);
            unchecked { ++i; }
        }

        // clear memory
        delete amounts;
    }

    function getFloorPrice(address token) external view returns (uint256) {
        return ( IERC20(token).balanceOf(address(this)) * 10**18 ) / IERC20(daylight).totalSupply();
    }

    function amountToRedeem(address token, uint256 amount) public view returns (uint256) {
        return ( IERC20(token).balanceOf(address(this)) * amount ) / IERC20(daylight).totalSupply();
    }

    function amountToRedeemWithFee(address token, uint256 amount) public view returns (uint256) {
        uint rAmount = amountToRedeem(token, amount);
        return rAmount - ( ( rAmount * redeemFee ) / feeDenominator );
    }

    function viewRedeemTokens() external view returns (address[] memory) {
        return tokens;
    }
}