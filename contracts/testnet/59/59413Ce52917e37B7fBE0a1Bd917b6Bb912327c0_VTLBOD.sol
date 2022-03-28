/**
 *Submitted for verification at BscScan.com on 2022-03-28
*/

// SPDX-License-Identifier: SimPL-2.0;
pragma solidity >=0.4.22 <0.7.0;

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
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
contract VTLBOD {
    using SafeMath for uint256;
    IERC20 public VTL;
    address contract_owner;
    address private _owner;
    address private marketingWallet = 0xBEbdbbEF5401A2cEEc3e9A465BB72C8Dc40D1992;
    
    uint s=10**18;
    uint256 total_by_amount = 150000000*s;
    uint256 total_boe_amount =50000000*s;
    uint256 use_by_amount=0;
    uint256 use_boe_amount=0;
    uint256 do_count = 0;
    constructor () payable public{
        if(contract_owner!=address(0)){
            return;
        }
        _owner = msg.sender;
        contract_owner=msg.sender;
        //VTL =IERC20(0xf2CA3F57760036B61Ea99a1F44CDdEdDD44090eF);
        VTL =IERC20(0xB2d2B237512234B68Cea6F80574f333506557618);
    }
    fallback() external payable{}
    receive() external payable{}
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function globalinfo() public view returns(uint _do_count,uint _use_by_amount,uint _use_boe_amount,address _marketingWallet){
        _do_count = do_count;
        _use_by_amount = use_by_amount;
        _use_boe_amount=use_boe_amount;
        _marketingWallet=marketingWallet;
    }
    function sendToBOE(address[] memory accounts) public onlyOwner {
        require(do_count <24, "Ownable: caller is not the owner");
        do_count=do_count+1;
        uint256 by_amount = total_boe_amount.div(24);
        use_by_amount=use_by_amount+by_amount;
        VTL.transfer(marketingWallet,by_amount);
        uint256 boe_amount = total_boe_amount.div(24).div(accounts.length);
        for(uint256 i=0;i<accounts.length;i++){
            use_boe_amount = use_boe_amount+boe_amount;
            address account=accounts[i];
            VTL.transfer(account,boe_amount);
        }
    }
}