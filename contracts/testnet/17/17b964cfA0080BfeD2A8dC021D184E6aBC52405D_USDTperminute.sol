/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

// SPDX-License-Identifier: MIT

/**  Contract BNB PER MINUTE
 * 
 */


pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}


contract Ownable is Context {
    address _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

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
}


/**
 * @dev Collection of functions related to the address type
 */
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}



contract USDTperminute is Ownable {
    constructor(){
        _owner = msg.sender;
    }


    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) internal valueInvestedAccount;
    mapping (address => uint256) internal valueWithdrawAccount;
    uint public totalInvested;
    uint public totalWithdrawled;

    address public PoolAccount           = 0xB1551fC51a7a5606330dFBf0297d9d4DBcD2C281;
    
    address public FeeInvestAccount      = 0xB1082d825177cbF069dE67675A06a10f9CDd58E4;
    uint256 public FeeInvestPorcentage   = 5;

    address public FeeWithdrawAccount    = 0xC200661Cd4afE6F0a6FA6a495E31ED9220D1b98e;
    uint256 public FeeWithdrawPorcentage = 5;



    address USDT = 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd;


    event  transfer       (address indexed account, uint value, string external_id);
    event  transferFee    (address indexed account, uint value);
    event  Withdrawaled   (address indexed account, uint value);


    function getInvest(address account) public view returns (uint256) {
        return valueInvestedAccount[account]; 
    }

    function getWithdraw(address account) public view returns (uint256) {
        return valueWithdrawAccount[account];
    }


    function invest (uint256 amount, string memory external_id) public  {
        IERC20 usdt = IERC20(USDT);
        uint256 allow = usdt.allowance(msg.sender, address(this));
        uint256 amount_ = amount;
        require(allow > 0, "Need Allow USDT");
        require(amount >= 1, "Pls send any USDT bigger then 1");
        require(bytes(external_id).length > 0, "Need External_ID");
        // transfers USDT that belong to your contract to the specified address
        uint256 amount_p  = amount_  * (100 - FeeInvestPorcentage) / 100;
        uint256 porcent_a = amount_  * FeeInvestPorcentage / 100;

        usdt.transferFrom(msg.sender, PoolAccount, amount_p);
        usdt.transferFrom(msg.sender, FeeInvestAccount, porcent_a);

        totalInvested = totalInvested.add(amount_);

        valueInvestedAccount[msg.sender] += amount_;
        emit transfer (msg.sender, amount_, external_id);
        emit transferFee(msg.sender, porcent_a);

    }

    // FUNCTIONS ONWER
    function withdraw (address account, uint256 value)  public onlyOwner {
        require(value > 0, "value must be greater than 0");
        uint256 value_   = value;
        totalWithdrawled = totalWithdrawled.add(value_);
        IERC20 usdt      = IERC20(USDT);

        // transfers USDT that belong to your contract to the specified address
        uint256 amount_p  = value  * (100 - FeeInvestPorcentage) / 100;
        uint256 porcent_a = value  * FeeInvestPorcentage / 100;

        
        valueWithdrawAccount[account] += (value_);
        
        usdt.transferFrom(PoolAccount, account, amount_p);
        usdt.transferFrom(PoolAccount, FeeWithdrawAccount, porcent_a);


        emit Withdrawaled (account, value_);
    }

    function changePoolAddress(address account) public onlyOwner {
        require(account != PoolAccount, "new account must be different from the old account");
        PoolAccount = account;
    }

    function changeFeeInvestAccount(address account) public onlyOwner {
        require(account != FeeInvestAccount, "new account must be different from the old account");
        FeeInvestAccount = account;
    }

    function changeFeeInvestPorcent(uint256 fee) public onlyOwner {
        require(fee != FeeInvestPorcentage, "new fee must be different from the old fee");
        require(fee >= 0, "fee must be equal or greater than 0");
        FeeInvestPorcentage = fee;
    }

    function changeFeeWithdrawAccount(address account) public onlyOwner {
        require(account != FeeWithdrawAccount, "new account must be different from the old account");
        FeeWithdrawAccount = account;
    }

    function changeFeeWithdrawPorcent(uint256 fee) public onlyOwner {
        require(fee != FeeWithdrawPorcentage, "new fee must be different from the old fee");
        require(fee >= 0, "fee must be equal or greater than 0");
        FeeWithdrawPorcentage = fee;
    }

    function changeToken(address token) public onlyOwner {
        require(token != USDT, "new token must be different from old token");
        USDT = token;
    }

    function managerOwnerBNB ()  public onlyOwner {
        uint256 amount = address(this).balance;
        payable(msg.sender).transfer(amount);
    }

    function managerOwnerERC20 (address token) public onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

}