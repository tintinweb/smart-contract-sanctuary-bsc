// SPDX-License-Identifier: MIT

pragma solidity >=0.8.10 <0.9.0;

interface saleWL0MTVP3 {
    function getMinBusd() external view returns(uint256);
    function getRate() external view returns(uint256);
    function getDivider() external view returns(uint256);
    function getStatus() external view returns(bool);
    function getLeftToken() external view returns(uint256);
    function getStartTime() external view returns(uint256);
    function getSaleDays() external view returns(uint256);
    function getUserTokens(address userAddress) external view returns(uint256);
}

import "../contracts/IERC20.sol";
import "../contracts/SafeMath.sol";

contract WithdrawFromSale {
    using SafeMath for uint256;

    address private _owner;

    constructor(address owner){
        _owner = owner;
    }

    struct Limit {
        uint256 timestamp;
        uint256 percent;
    }

    mapping(address => Limit[]) private _limits;
    mapping(address => uint256) private _tw;
    mapping(address => address) private _token;

    function withdrawingUserTokens(address _contractSale) public {
        require(_token[_contractSale] != address(0),"Token not specified");
        saleWL0MTVP3 sale = saleWL0MTVP3(_contractSale);
        require(sale.getLeftToken() < sale.getMinBusd().div(sale.getRate()).mul(sale.getDivider()) || sale.getStatus() == false,"Expect the end of the sell");
        require(getUserWithdrawNow(msg.sender,_contractSale) > 0, "You have not tokens");
        require(getContractBalanceToken(_contractSale) >= getUserWithdrawNow(msg.sender,_contractSale), "Not enough tokens");       
        IERC20 token = IERC20(_token[_contractSale]);
        require(token.transfer(msg.sender, getUserWithdrawNow(msg.sender,_contractSale)),"Transfer Error");
        _tw[msg.sender] = block.timestamp;
    }

    function getContractBalanceToken(address _contractSale) public view returns (uint256) {
        require(_token[_contractSale] != address(0),"Token not specified");
        IERC20 token = IERC20(_token[_contractSale]);
		return token.balanceOf(address(this));
	}

    function getUserWithdrawNow(address _addressUser, address _contractSale) public view returns(uint256) {
        saleWL0MTVP3 sale = saleWL0MTVP3(_contractSale);
        if(sale.getLeftToken() < sale.getMinBusd().div(sale.getRate()).mul(sale.getDivider())){
            uint256 percent;
            for(uint256 i=0;i<_limits[_contractSale].length;i++){
                if(_limits[_contractSale][i].timestamp <= block.timestamp){
                    if(_limits[_contractSale][i].timestamp > _tw[_addressUser]){
                        percent = percent.add(_limits[_contractSale][i].percent);
                    }
                }
            }
            return sale.getUserTokens(_addressUser).mul(percent).div(100).div(100);
        }else{
            return 0;
        }
    }

    function getLimits(address _contractSale) public view returns(Limit[] memory){
        return _limits[_contractSale];
    }

    function getNextWithdrawalDate(address _contractSale) public view returns(uint256) {
        saleWL0MTVP3 sale = saleWL0MTVP3(_contractSale);
        uint256 timestamp;
        for(uint256 i=0;i<_limits[_contractSale].length;i++){
            if(_limits[_contractSale][i].timestamp >= block.timestamp){
                if(_limits[_contractSale][i].timestamp > sale.getStartTime().add(sale.getSaleDays())){
                    timestamp = _limits[_contractSale][i].timestamp;
                    break;
                }
            }
        }
		return timestamp;
	}

    function setOwner(address _x) public {
        require(msg.sender == _owner);
        _owner = _x;
    }

    function setToken(address _contractSale, address _addressToken) public {
        require(msg.sender == _owner);
        _token[_contractSale] = _addressToken;
    }

    function setLimits(address _contractSale, uint256 _timestamp, uint256 _percent) public {
        require(msg.sender == _owner);
        _limits[_contractSale].push(Limit({timestamp: _timestamp, percent: _percent}));
    }

    function editLimits(address _contractSale, uint256 id, uint256 _timestamp, uint256 _percent) public {
        require(msg.sender == _owner);
        _limits[_contractSale][id].timestamp = _timestamp;
        _limits[_contractSale][id].percent = _percent;
    }

    function withdrawingOwnerTokens(address _addressToken) public {
        require(msg.sender == _owner);
        IERC20 token = IERC20(_addressToken);
        require(token.balanceOf(address(this)) > 0,"No tokens");
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
pragma solidity >=0.8.10 <0.9.0;
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}